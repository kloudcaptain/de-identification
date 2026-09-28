Document De-identification Lab (Azure, AKS, Terraform)

This is a hands-on Azure lab that builds the infrastructure for a self-hosted document de-identification service. The service detects and redacts PII and PHI from clinical style documents before they move into research, analytics, or anywhere downstream. I built it with a healthcare and pharma context in mind, where protected health information can't leak and every access to a document has to be provable.

Everything here is defined in Terraform. The whole point was to work through the security and cost decisions a cloud engineer actually makes rather than just get something running: keeping sensitive data off the public internet, granting access by identity instead of stored credentials, encrypting under keys the operator controls, keeping a real audit trail, and being honest about what a lab deploys versus what production would need.

Architecture

Show Image

Primary region is East US 2.

Public clients reach the service through an Azure Standard Load Balancer, which AKS provisions through a Kubernetes Service of type LoadBalancer. That routes to an NGINX ingress controller running inside the cluster.

The AKS cluster runs three logical pieces. There's the document-processing workload itself (the de-identification pods), a small system node pool that stays on all the time, and a GPU node pool that scales down to zero when nothing needs it, so GPU cost only shows up while documents are actually being processed.

The network is segmented. Everything sits inside one virtual network at 10.0.0.0/16, split into an AKS cluster subnet at 10.0.1.0/24 and a private endpoint subnet at 10.0.2.0/24, each with its own network security group. Outbound traffic leaves through a NAT Gateway for deterministic SNAT, and no cluster node gets a public IP. A private DNS zone resolves the private endpoints for blob, database, ACR, and vault.

All the backend resources are reachable only through private endpoints, never over the public internet:

Azure Blob Storage holds the documents
Azure SQL Database holds the audit logs
Azure Container Registry holds the de-identification container image
Azure Key Vault holds application secrets and the customer-managed encryption keys

For identity, the AKS service account federates to a user-assigned managed identity through workload identity, so the workload authenticates with nothing hardcoded. Access comes from narrowly scoped Azure roles: Storage Blob Data Reader, Key Vault Secrets User, AcrPull, a SQL data-plane role, Log Analytics Reader, and Monitoring Reader. None of the infrastructure roles give any path to the document data itself.

Key Vault does two separate jobs on separate access paths. Application secrets are read by the workload through Key Vault Secrets User. The customer-managed keys are used by the storage and database managed identities to encrypt data at rest. Keeping those paths apart is deliberate.

On the audit side, the document-processing workload writes an event on every document access. Each event records the identity, document ID, operation, timestamp, and authorization result, and never the document contents. Those events go to a Log Analytics workspace through Azure Monitor.

A few things are drawn on the diagram as design considerations but aren't deployed in the lab: Application Gateway with WAF, Microsoft Defender for Containers, multi-region DR, and Azure Backup. Leaving them out is a cost decision for a lab, and I'd rather state that plainly than pretend the lab is production ready.

What I was going for
Keep protected data private. It never touches the public internet.
Use identity instead of secrets. Federated workload identity and least-privilege roles rather than stored credentials.
Keep cost low by design. The environment tears down and rebuilds between sessions, the GPU pool scales to zero, and nothing runs that isn't being used.
Keep it reusable. Nothing subscription-specific is hardcoded, so anyone can clone it and deploy into their own subscription.
Be honest about scope. What's deployed and what's deferred are clearly separated.
Before you start

You'll need:

An Azure subscription
Azure CLI, installed and logged in with az login
Terraform 1.9 or newer
kubectl, to talk to the cluster once it's up

You also need enough vCPU quota in your region for the node pool sizes. If a deploy fails with a quota or SKU availability error, check what your region actually allows:

az vm list-usage --location <your-region> --output table

I hit this myself. The size I originally planned wasn't available in my subscription, and running that command is how I found one that was.

Setup

All the settings are Terraform variables, so there's nothing subscription-specific baked into the code.

Copy the example variables file:

cp terraform.tfvars.example terraform.tfvars

Then set your subscription ID in terraform.tfvars:

subscription_id = "<your-azure-subscription-id>"

terraform.tfvars is gitignored and never gets committed. Region, resource group name, and node sizes all have defaults in variables.tf, so override them here only if you want something different.

One note on the IDs: subscription and tenant IDs are identifiers, not secrets, so referencing them is fine. Credentials like client secrets or access keys are a different story and never belong in the repo. This lab authenticates through your local Azure CLI session, so there's no secret stored in the code at all.

Deploying
terraform init
terraform plan
terraform apply

Once it's applied, connect to the cluster:

az aks get-credentials --resource-group <rg-name> --name <cluster-name> --overwrite-existing
kubectl get nodes

You should see one node come back as Ready.

Tearing it down
terraform destroy

That removes the cluster, the resource group, and the AKS-managed MC_ resource group that Azure creates on its own. You can confirm nothing's left behind:

terraform show

After a destroy it reports no resources. Rebuilding takes a few minutes, which is the whole idea. The environment only runs while I'm actually using it.

How the repo is laid out
.
├── main.tf                    resource group and module calls
├── providers.tf               Terraform and azurerm provider config
├── variables.tf               root input variables
├── outputs.tf                 root outputs
├── terraform.tfvars.example   template for your own values (committed)
├── terraform.tfvars           your actual values (gitignored)
├── .gitignore
├── docs/
│   └── architecture.png       the diagram above
└── modules/
    └── aks/                   the AKS cluster module
        ├── main.tf
        ├── variables.tf
        └── outputs.tf

State is kept locally since this is a solo lab. It's gitignored and backed up to a private repo, never the public one. If you were doing this with a team you'd want a remote backend instead, like an Azure Storage account.

Where this stands

I'm building this in stages, tracked as issues in the repo (features, epics, and user stories with acceptance criteria). Roughly:

Repeatable, low-cost lab platform. Walking skeleton, teardown and rebuild. Done.
Secure network. Segmented VNet, NSGs, controlled egress, private endpoints, private DNS. In progress.
Zero-trust identity and encryption. Workload identity, least-privilege roles, Key Vault secrets and customer-managed keys. Planned.
De-identification service and audit trail. The GPU-backed workload and the document-access audit log. Planned.
Operational visibility. Container Insights and central logging. Planned.
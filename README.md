# GCP Terraform
Brandfolder's Infrastructure running on Google Cloud Platform.

## STEP 1: Booting the machines in the cluster.

1.  Copy `example.tfvars` to `terraform.tfvars` and populate it with the desired
    values.

    ```sh
    cp example.tfvars terraform.tfvars
    $EDITOR terraform.tfvars
    ```

2.  Plan terraform and inspect the changes.
    > Note: If you use atlas skip this step and see the 'Atlas setup' section
      below.

    ```sh
    terraform plan
    ```

3.  If everything looks good, apply it.
    > Note: If you use atlas skip this step and see the 'Atlas setup' section
      below.

    ```sh
    terraform apply
    ```

4.  SSH into your bastion host. (If you specified a prefix, replace `bastion` with `{prefix}bastion`.)

    ```sh
    gcloud compute ssh bastion
    ```

5.  You should be able to list the machines in the cluster. If so then you are ready for the next step.

    ```sh
    sudo fleetctl list-machines
    ```

## STEP 2: Setting up vault and generating certificates.

1.  The vault servers should be loaded on every machine in the cluster, to
    confirm run the following while ssh'd into the bastion host:

    ```sh
    fleetctl list-units | grep vault
    ```

2.  You should now be able to initialize vault. Copy the output to a secure
    location. This contains the information necessary to unseal the vault.
    > Note: The most secure location is a ***physical safe*** or a
      ***safety deposit box***.

    ```sh
    vault init
    ```

3.  You now need to unseal vault. Follow the prompts, you will need 3 of the
    keys from #2 in this step.

    > Note: You will always need at least 1 vault server to be unsealed at all
      times in the cluster for new kubelets to boot properly. We suggest
      unsealing at least 2 servers to account for failover.

    ```sh
    vault unseal
    ```

4.  Now that vault is set up we can generate the certificates. Follow the
    prompts. You will need the root token from #2 in this step.

    ```sh
    vault-generate-certs
    ```

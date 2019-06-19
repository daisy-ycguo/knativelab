# Prepare a Kubernetes cluster and CloudShell

Knative Lab uses IBM Kubernetes Service on IBM Cloud. If you have not got a IBM Cloud ID, go to register at [http://cloud.ibm.com](http://cloud.ibm.com).

## Assign a Kubernetes Cluster

We have pre allocate 50 Kubernetes Clusters. Go to the instructor to allocate a cluster.

After you have been allocated a cluster, login to [IBM Cloud](http://cloud.ibm.com), look for your cluster under [Kubernetes Cluster](https://cloud.ibm.com/kubernetes/clusters) page.

## Prepare CloudShell

Go to [CloudShell](https://cloudshell-console-ikslab.us-south.cf.cloud.ibm.com/) page, get the password from the instructor.

Using the account drop down, choose the IBM account.

Click on the Terminal icon to launch your web shell.

In the web terminal window, input `git` and see the correct output information.

```text
git
```

## Clone the source code for this lab

Clone the source code to your web terminal by:

```text
git clone https://github.com/daisy-ycguo/knativelab.git
```

## Connect to your Kubernetes Cluster

Go to your Kubernetes Cluster page, under the Access, there are detailed instructions to access Kubernetes with command line.

In your CloudShell window, follow the instructions in Access page. Please note that you should skip the first step "download CLI tool" because the CLI tools have been installed in your CloudShell.

When you can get correct response from `kubectl get nodes`, you are able to connect to your cluster with command line. You can continue the lab now.

Continue [exercise 1](../exercise-1/).


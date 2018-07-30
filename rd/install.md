### Installing Actifio Resiliency Directory (RD)

The Actifio Resiliency Director Server is a component of the Actifio Resiliency Director, a complete resiliency solution for non-disruptive automated recovery of virtual machines and virtual applications.

The Actifio Resiliency Director orchestrates the Actifio Appliances, and provides a one-click recovery of all the applications at the enterprise DR site on the Cloud Service Provider (CSP) site.

The Actifio Resiliency Director Server is the central manager of resiliency data for multiple Resiliency Director Collectors. Data collected by the Actifio Resiliency Director Collector is sent and saved in the Actifio Resiliency Director Server. This enables Actifio Resiliency Director Server to bring all VMs online in an orchestrated manner in case of failover, or move the VM stacks to cloud for tasks such as data mining, analysis, and optimization.


#### RD VM Requirements

You can deploy the Actifio Resiliency Director Collector on the vCenter Server 5.5 - 6.0  

To deploy the RD OVA, use VMware vSphere 6.5, 6.0, 5.5 or 5.1 Web Client with the following minimum system requirements:  

Following are the minimum system requirements for Actifio Report Manager deployment:
- 2 virtual CPUs*
- 8 GB of memory
- 40 GB VMDK disk space
- One(1) virtual network interface card (vNIC)
- A static (and unique) IPv4 address


##### VMFS Data store
CDS and Sky require a VMFS (not NFS) data store to perform a failover or test-failover action. This is because they will present block devices and create raw device mappings (RDMs) into the recovered VMs. ESX can only store the needed RDM mapping files on block devices formatting with VMFS. Note: shared VMFS data stores are needed for dynamic balancing of VM load across the cluster, see best practices section below for additional information.

##### VMware Enterprise & Resource Pools
RD requires resource pools for ESX host selection during execution of a recovery plan. VMware supports creation of resource pools only with the Enterprise licensed product.

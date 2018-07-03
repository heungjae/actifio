### Installing Actifio Sky

Actifio Sky™ is a robust virtual appliance built on Actifio’s patented Virtual Data Pipeline™ (VDP) that powers the data center appliance Actifio CDS™. Actifio Sky offers a new level of deployment flexibility and range. As a virtual appliance, Actifio Sky can be deployed in minutes at any site across an organization’s locations and environments.

#### vSphere Server Requirements
An Actifio Sky VM must be installed on a VMware vSphere server configured specifically for an Actifio Sky VM.

##### Sky 1TB license
- Reserved 1 virtual CPUs*
- Reserved 6 GB of memory
- minimum disk space for primary pool - 400GB
- minimum disk space for snapshot pool - 10GB, (recommended 500GB)
- minimum disk space for dedup pool - 1TB (use Thick Provision Eager Zero disks)  
- optional SSD - 11GB

##### Sky 5TB license
- Reserved 2 virtual CPUs*
- Reserved 10 GB of memory
- minimum disk space for primary pool - 400GB
- minimum disk space for snapshot pool - 10GB, (recommended 500GB)
- minimum disk space for dedup pool - 1TB (use Thick Provision Eager Zero disks)  
- optional SSD - 53GB

##### Sky 10TB license
- Reserved 4 virtual CPUs*
- Reserved 16 GB of memory
- minimum disk space for primary pool - 400GB
- minimum disk space for snapshot pool - 10GB, (recommended 500GB)
- minimum disk space for dedup pool - 1TB (use Thick Provision Eager Zero disks)  
- optional SSD - 103GB

Also, when creating disks on ESX, ensure that the Mode is set to Independent and Persistent.

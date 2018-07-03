### Installing Actifio Global Manager (AGM)

Actifio Global Manager (AGM) provides centralized management capabilities in a virtual appliance that can be deployed on standard VMware ESX servers. From one centralized AGM management system, you use the AGM web-based UI to manage multiple Actifio CDS and Actifio Sky appliances and perform various day-to-day copy data operations. Actifio appliances are the highly scalable copy data platforms that virtualize application data to improve the resiliency, agility, and cloud mobility of your business.


#### AGM VM Requirements
To deploy the AGM OVA without the AGM Catalog feature enabled, use VMware vSphere 6.5, 6.0, 5.5 or 5.1 Web Client with the following minimum system requirements:

##### AGM Without Catalog Enabled

`Note: The deployment and installation of the AGM OVA using a standalone ESXi host is not supported.`  
- Reserved 4 virtual CPUs*
- Reserved 8 GB of memory
- 50 GB free datastore space**
- One(1) virtual network interface card (vNIC)
- A static (and unique) IPv4 address***

`
*Both the virtual CPU and virtual RAM allocation should be reserved.
** Avoid sharing the datastore space with production load.
`

##### AGM With Catalog Enabled
To deploy the AGM OVA with AGM’s Catalog feature enabled, use the VMware vSphere 6.5, 6.0, 5.5 or 5.1 Web Client with the following system requirements:

`Note: AGM with Catalog must be installed on ESX server that has vSphere/ESX 5.x or higher installed.`  
- Reserved 8 virtual CPUs*
- Reserved 20 GB of memory
- 300GB of storage - 50GB for the operating system and 250GB for index store. Do not share the datastore with your production load.
- 400GB of storage - A separate disk is required to store backup catalog data. Do not share the datastore with the production load.

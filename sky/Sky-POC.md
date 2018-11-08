## Setting up Sky for POC


**Sky - Prerequisites for POC:
	
- [ ] Verify network ports are open for Actifio SKY communication and replication
- [ ] Refer to PORT LIST tab in this document
- [ ] On ESX, verify it is running version ESXi 5.0 - 5.5, 6.0 u1-u21 ,u3, 6.5
- [ ] On ESX, install, enable ISCSI initiator on the ESX host
   
- [ ] On vCenter, disable PowerManagement, ensure that power management for the ESX host is set to High Performance.
- [ ] On vCenter, do not use VMware Tools periodic time synchronization for the Actifio Sky appliances’ VM. Use NTP instead.
- [ ] On vCenter, verify ESX TimeSettings set to use NTP
- [ ] On vCenter, turn off balloning driver
- [ ] On vCenter, modify the SCSI controllers to ParaVirtual 
  
- [ ] On Sky, identify IP Address, DNS Server Name, Subnet Mask, NTP Server Address to be used for Sky
- [ ] Download SKY OVA - link provided by Actifio 

- [ ] On ESX, apply CPU (4), RAM (12GB) to Sky VM
- [ ] On ESX, configure 3 VMDK's in independent persistent mode, thick-provisioned, eager 0.
- [ ] 1 x 400 GB = Primary Pool (0:0 controller)
- [ ] TBD TB   = Snapshot Pool (1:x controller)
- [ ] TBD TB   = Dedup Pool (2:x controller) 
- [ ] The controllers for the Actifio Snapshot Pool and Dedup Pool must be set to VMware Paravirtual.
   
- [ ] Deploy SKY - Power Up VM, open a browser and go to the installer page:  IP address/installer
   
- [ ] Follow steps in Actifio SKY for VMware installation Guide
   
- [ ] Verify the correct Actifio Sky License for data capacity is provided (5TB, 10TB, 30TB & 50TB)

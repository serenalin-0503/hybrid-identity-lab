# Hybrid Identity Lab — On-Prem AD on VirtualBox

A home lab I built to learn Active Directory and prep for the SC-300 (Microsoft Identity and Access Administrator) certification. The goal is to set up a working on-prem AD environment that I can later connect to Microsoft Entra ID and use for things like Conditional Access, PIM, and Access Reviews.

## What the lab looks like

- **Host:** Windows 11 laptop
- **Hypervisor:** Oracle VirtualBox
- **Network:** A private NAT network (10.0.2.0/24) so the lab VMs are isolated from my real network
- **DC01:** Windows Server 2022, 4 GB RAM, static IP 10.0.2.10
- **Domain:** `contoso.local`

## What I've built so far

### Phase 1 — Set up the VirtualBox network
Created a NAT network called `LAB-NAT` so the lab VMs talk to each other but stay separate from my home network.

![NAT Network](screenshots/01-virtualbox-natnet.png)

### Phase 2 — Build the DC01 virtual machine
Created the VM that will become the domain controller. Windows Server 2022, attached to the LAB-NAT network, with a static IP of `10.0.2.10` so it doesn't change.

![DC01 settings](screenshots/02a-dc01-virtualbox.png)
![ipconfig](screenshots/02c-ipconfig.png)

### Phase 3 — Install AD and promote the server to a domain controller
Installed the Active Directory, DNS, and management tool roles, then ran a script ([`scripts/promote-dc.ps1`](scripts/promote-dc.ps1)) to turn the server into a domain controller for `contoso.local`. The script asks for the recovery password when it runs — I never write the password into the file itself.

After it finished, I checked that the four main AD services (ADWS, DNS, KDC, NTDS) were running.

![Features installed](screenshots/03a-features-installed.png)
![Domain promoted](screenshots/03b-domain-promoted.png)
![Services running](screenshots/03c-services-running.png)

### Phase 5 — Fill the domain with realistic test data
A brand new domain only has the Administrator account, which isn't useful for practicing. So I wrote a PowerShell script ([`scripts/02-populate-ad.ps1`](scripts/02-populate-ad.ps1)) that creates:

- An OU (organizational unit) structure that mirrors how a real company would organize things — separate areas for admin tiers, regular users, groups, and disabled accounts
- Department OUs for Finance, HR, IT, Marketing, and Sales
- A security group for each department (`GG-Finance-Users`, `GG-HR-Users`, etc.)
- 50 test users spread across the departments, each one added to their department's group

The script is **safe to re-run** — every time it tries to create something, it first checks if it already exists. If it does, it skips it. So I can run the script ten times in a row and end up with the same 50 users, no errors and no duplicates.

![OU tree in ADUC](screenshots/04-ou-tree-aduc.png)
![Users per department](screenshots/04-users-per-department.png)
![Security groups](screenshots/04-security-groups.png)
![User group membership](screenshots/04-user-group-membership.png)
![Script execution](screenshots/04-script-execution.png)
![VirtualBox snapshots](screenshots/04-virtualbox-snapshots.png)

The department security groups matter because they'll later sync to Microsoft Entra ID. Once they're up there, I can use them to target Conditional Access policies — for example, "require MFA for everyone in Finance."

## What's next

- **Phase 6:** Install Microsoft Entra Connect and sync the on-prem users and groups to a cloud tenant
- **Phase 7:** Apply Conditional Access policies that target the synced groups
- **Phase 8:** Set up PIM (Privileged Identity Management) so admin roles are only active when needed
- **Phase 9:** Configure Access Reviews and Global Secure Access

## Notes on security

- Both PowerShell scripts ask for passwords when they run instead of having passwords typed into the file. No passwords are saved in this repo.
- I blurred out unique IDs (domain SID and ObjectGUIDs) in the screenshots, even though `contoso.local` only exists inside my VirtualBox.

## About me

Built by Serena Lin while studying for SC-300.

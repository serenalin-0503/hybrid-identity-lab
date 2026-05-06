# Populate contoso.local with OUs, groups, and 50 test users
$Domain = "DC=contoso,DC=local"

# --- 1. Top-level OUs --- 
$TopOUs = @("Corp","Tier1","Tier2","Disabled")
foreach ($ou in $TopOUs) {
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$ou'" -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $ou -Path $Domain -ProtectedFromAccidentalDeletion $true
    }
}

# --- 2. Sub-OUs under Corp ---
$CorpPath = "OU=Corp,$Domain"
$SubOUs = @("Users","Groups","ServiceAccounts","Workstations")
foreach ($ou in $SubOUs) {
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$ou'" -SearchBase $CorpPath -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $ou -Path $CorpPath -ProtectedFromAccidentalDeletion $true
    }
}

# --- 3. Department OUs under Corp\Users ---
$UsersPath = "OU=Users,OU=Corp,$Domain"
$Departments = @("Finance","HR","IT","Marketing","Sales")
foreach ($dept in $Departments) {
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$dept'" -SearchBase $UsersPath -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $dept -Path $UsersPath -ProtectedFromAccidentalDeletion $true
    }
}

# --- 4. Department security groups ---
$GroupsPath = "OU=Groups,OU=Corp,$Domain"
foreach ($dept in $Departments) {
    $gname = "GG-$dept-Users"
    if (-not (Get-ADGroup -Filter "Name -eq '$gname'" -ErrorAction SilentlyContinue)) {
        New-ADGroup -Name $gname -GroupScope Global -GroupCategory Security `
            -Path $GroupsPath -Description "All users in $dept"
    }
}

# --- 5. Test user generator ---
$FirstNames = @(
    "Aiden","Bella","Carlos","Diana","Ethan","Fatima","Grace","Hiro","Ivy","Jamal",
    "Kira","Liam","Maya","Noah","Olivia","Priya","Quinn","Riley","Sophie","Tariq",
    "Uma","Victor","Wendy","Xavier","Yara","Zane","Anna","Ben","Chloe","Dmitri",
    "Eva","Felix","Gina","Henry","Iris","Jax","Kai","Lena","Mateo","Nora",
    "Omar","Pearl","Quentin","Rosa","Sam","Tara","Ulysses","Vera","Will","Yusuf"
)

$LastNames = @(
    "Anderson","Brown","Chen","Davis","Evans","Foster","Garcia","Huang","Iqbal","Jones",
    "Kim","Lee","Martinez","Nguyen","Okonkwo","Patel","Quinn","Rossi","Smith","Tanaka",
    "Ueno","Vargas","White","Xu","Young","Zhang","Adams","Baker","Cohen","Diaz",
    "Edwards","Ford","Green","Hall","Ito","Jackson","Khan","Lopez","Miller","Novak",
    "Olsen","Park","Qureshi","Reyes","Singh","Thomas","Uddin","Volkov","Wright","Yang"
)

# Lab password is prompted at runtime rather than hardcoded
$Password = Read-Host -Prompt "Enter lab user password" -AsSecureString
$Created = 0

for ($i = 0; $i -lt 50; $i++) {
    $first  = $FirstNames[$i]
    $last   = $LastNames[$i]
    $dept   = $Departments | Get-Random
    $sam    = ("$first.$last").ToLower()
    $upn    = "$sam@contoso.local"
    $deptOU = "OU=$dept,OU=Users,OU=Corp,$Domain"

    if (-not (Get-ADUser -Filter "SamAccountName -eq '$sam'" -ErrorAction SilentlyContinue)) {
        New-ADUser `
            -Name "$first $last" `
            -GivenName $first `
            -Surname $last `
            -SamAccountName $sam `
            -UserPrincipalName $upn `
            -DisplayName "$first $last" `
            -Path $deptOU `
            -AccountPassword $Password `
            -Enabled $true `
            -Department $dept `
            -Title "$dept Specialist" `
            -EmailAddress $upn `
            -ChangePasswordAtLogon $false

        Add-ADGroupMember -Identity "GG-$dept-Users" -Members $sam
        $Created++
    }
}

Write-Host "Created $Created users across $($Departments.Count) departments." -ForegroundColor Green
# UniFi Firewall Configuration

## Network Overview

### VLANs

- **Default** - VLAN 1 (System-defined, required by UniFi)
- **Home** - VLAN 10 - Wired devices: illmatic, shield, hdhr, ps3, cbox (DHCP: 10.42.10.100-254)
- **IoT** - VLAN 20 - ecobee, harmony hub (DHCP: 10.42.20.6-254)
- **Guest** - VLAN 30 - Guest devices (DHCP: 10.42.30.6-254)
- **Work** - VLAN 40 - ruca workstation only (DHCP: 10.42.40.100-254)
- **WIFI** - VLAN 50 - WiFi devices, client isolation enabled (DHCP: 10.42.50.6-254)
- **Management** - VLAN 100 - UniFi gateway, switches, APs (DHCP: 10.42.100.6-254)

### Key Devices

- **ruca**: Desktop workstation (Work VLAN)
- **illmatic**: NAS/home server - runs Immich, Blocky, Forgejo, Jellyfin, Channels DVR (Home VLAN)
- **cbox**: Old Chromebox for Blocky DNS (Home VLAN)
- **lappy**: Laptop with VPN (mobile)
- **shield**: NVIDIA Shield (Home VLAN)
- **ps3**: PlayStation 3 (Home VLAN)
- **ecobee**: Thermostat (IoT VLAN)
- **harmony hub**: (IoT VLAN)
- **hdhr**: Network tuner (Home VLAN)
- **Pixel 9**: Phone (varies)

### DNS Servers

- **illmatic**: Primary Blocky DNS
- **cbox**: Secondary Blocky DNS

## Objectives

1. **Work VLAN (ruca)** - Isolated from everything else
   - No inbound access (except future VPN for SSH)
   - Can access almost everything outbound (Home services, Management, Internet)

2. **DNS** - Runs locally via Blocky on illmatic and cbox (Home VLAN)

3. **IoT** - Isolated, Internet access only
   - No access to Home or Work VLANs
   - May need DNS access to Blocky servers

4. **Management** - Separate VLAN for network infrastructure
   - Only accessible from Work VLAN (and future VPN)

## Configuration

### Current Setup

**Zone Organization:**
- **Trusted zone**: Home, IoT, Work, WIFI VLANs (custom zones auto-isolate VLANs)
- **Management zone**: Management VLAN only (isolated)
- **Internal zone**: Default, Guest VLANs

**DNS Configuration:**
- **Work & Home VLANs**: Use local DNS (illmatic, ruca - Blocky for ad blocking)
- **WIFI VLAN**: Use local DNS (ruca, illmatic - Blocky for ad blocking)
- **IoT VLAN**: Public DNS (8.8.8.8, 1.1.1.1) - no local domain resolution needed
- **Management VLAN**: Public DNS (1.1.1.1, 8.8.8.8) - gateway manages firmware
- **Guest VLAN**: Your choice (local for ad blocking or public)

**Firewall Rules:** Simplified zone-based rules + IP-specific gateway access:
1. Trusted → Trusted (allows Work/Home/IoT/WIFI inter-VLAN communication)
2. Trusted → DNS (ports 53 to Home and Work VLANs)
3. ruca IP → Gateway (all ports - SSH, API, web UI access)
4. illmatic IP → Gateway (ports 80, 443 - reverse proxy with valid SSL cert)
5. Block All Other → Gateway Admin Ports (deny 22, 80, 443, 8443)

**Behavior:**
- Custom zones (Trusted, Management) have "Block All" by default between VLANs
- Only explicitly allowed traffic (via firewall rules) can pass between zones
- Work VLAN (ruca) has full access to Trusted zone (Home, IoT, WIFI) and Gateway
- WIFI VLAN uses local DNS with client isolation enabled (devices can't see each other)
- IoT uses public DNS, isolated from local network (only internet access)
- Only ruca and illmatic can access Gateway admin interfaces

## Traffic Flow Examples

### Allowed Connections

**Within Trusted Zone:**
- **ruca → illmatic:8080** (Immich) ✅ - Rule 1 (Trusted → Trusted)
- **ruca → illmatic:8096** (Jellyfin) ✅ - Rule 1 (Trusted → Trusted)
- **ruca → illmatic:53** (DNS) ✅ - Rule 1 + Rule 2 (DNS)
- **shield → illmatic:8096** (Jellyfin) ✅ - Rule 1 (Trusted → Trusted)
- **illmatic → ruca:53** (DNS) ✅ - Rule 2 (DNS)
- **Home devices ↔ each other** ✅ - Rule 1 (Trusted → Trusted)

**Internet Access:**
- **ruca → internet** ✅ - Trusted → External (default allow)
- **ecobee → internet** (firmware) ✅ - Trusted → External (default allow)
- **ecobee → 1.1.1.1:53** (public DNS) ✅ - Uses public DNS, internet access
- **guest device → internet** ✅ - Internal → External (default allow)

**Gateway Admin Access:**
- **ruca → gateway:22** (SSH) ✅ - Rule 3 (ruca → Gateway)
- **ruca → gateway:443** (web UI) ✅ - Rule 3 (ruca → Gateway)
- **ruca → gateway API** ✅ - Rule 3 (ruca → Gateway)
- **illmatic → gateway:443** (reverse proxy) ✅ - Rule 4 (illmatic → Gateway)
- **Browser → unifi.home.local:443** (via illmatic proxy with valid SSL) ✅ - Rule 4

### Blocked Connections

**Gateway Admin Port Blocking:**
- **shield → gateway:443** ❌ - Rule 5 (blocked by deny rule)
- **ecobee → gateway:22** ❌ - Rule 5 (blocked by deny rule)
- **guest device → gateway:443** ❌ - Rule 5 (blocked by deny rule)
- **Any device except ruca/illmatic → gateway admin ports** ❌ - Rule 5

**VLAN Isolation (if you add more specific rules later):**
- **ecobee → illmatic:8080** - Depends on your Trusted → Trusted rule scope
- **guest device → illmatic:8096** ❌ - Internal zone isolated from Trusted zone
- **guest device → ruca:22** ❌ - Internal zone isolated from Trusted zone
- **Any device from internet → ruca** ❌ - NAT + no port forward + firewall

**Management VLAN Isolation:**
- **Any device → Management VLAN** ❌ - Management zone isolated by default
- **Work would need explicit rule** to access Management VLAN devices (switches, APs)

## Verification Commands

After implementing the zone changes, verify with:

```bash
# Check zone assignments
cd ~/.claude/skills/unifi-gateway-api/scripts
npx ts-node unifi-client.ts firewall-zones

# Check networks and DNS configuration
npx ts-node unifi-client.ts network-details

# Check networks
npx ts-node unifi-client.ts networks

# Check ACL rules (if visible via API)
npx ts-node unifi-client.ts acl-rules
```

## Troubleshooting Notes

### WiFi Connection Issues on Home Network

**Problem**: WiFi clients unable to connect to Home VLAN (VLAN 10) while IoT and Work VLANs worked fine.

**Initial Investigation**: Compared network configurations:
- Home VLAN: DHCP range 10.42.10.100-254 (restricted range)
- IoT/Work VLANs: DHCP range 10.42.x.6-254 (full range)
- DNS, zone assignments, and other settings appeared correct

**Solution**: Created separate WIFI VLAN (VLAN 50) dedicated to WiFi devices instead of troubleshooting the original Home network configuration.

**Result**:
- Home VLAN (10) now used exclusively for wired devices
- WIFI VLAN (50) used for all wireless devices with client isolation enabled
- Both VLANs in Trusted zone with access to Home services
- WIFI uses local DNS (ruca, illmatic) for ad blocking

**Lesson**: Sometimes creating a fresh network configuration is more efficient than debugging subtle issues in an existing setup. The separation of wired/wireless networks also provides better security through client isolation on WiFi.

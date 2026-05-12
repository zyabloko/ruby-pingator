# Pingator — IP Availability Monitoring System

A lightweight API service for registering IP addresses, monitoring their availability via ICMP ping, and calculating detailed uptime statistics over configurable time periods.

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/ips` | Register a new IP address. Params: `ip` (IPv4/IPv6), `enabled` (bool) |
| `POST` | `/ips/:id/enable` | Enable monitoring and stats collection for an IP |
| `POST` | `/ips/:id/disable` | Disable monitoring and stats collection for an IP |
| `GET` | `/ips/:id/stats` | Fetch statistics for an IP. Params: `time_from`, `time_to` (datetime) |
| `DELETE` | `/ips/:id` | Disable monitoring and remove the IP address |

---

## Requirements

### Polling

- Availability checks must run on a configurable interval (e.g. every minute)
- If a check takes longer than **1 second**, it is treated as a failed probe (packet loss) and must be aborted

### Statistics

Calculated entirely at the **database level**, covering the requested time period:

- Average RTT
- Minimum RTT
- Maximum RTT
- Median RTT
- Standard deviation of RTT
- ICMP packet loss percentage

### Interval Handling

- If an IP was partially outside monitoring during the requested period (not yet added, deleted, or disabled), those gaps are **excluded** from the calculation
- Enabled intervals are **merged** before computing stats

  > **Example:** if an IP was enabled 1–2h, then re-enabled 3–4h, a query from 1–4h merges both intervals and returns stats over the combined active window

- If the IP had **no active monitoring** during the requested period, or was active for too short a time to collect at least one measurement — return an **error response**

### Stack Constraints

- No Rails (ActiveSupport and ActiveRecord are permitted)

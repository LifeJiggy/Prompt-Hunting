# Automation-Efficiency 31: Cost Optimization Strategies

## Expert Role

You are an elite Bug Bounty Cost Optimization Engineer specializing in maximizing return on investment for security testing operations. You understand that bug bounty hunting involves real costs: cloud compute, API subscriptions, proxy services, tool licenses, and your own time. Your expertise lies in quantifying these costs, identifying waste, and implementing strategies that reduce expenses while maintaining or improving testing effectiveness.

Your core competencies include:
- Building cost tracking and attribution systems for bug bounty operations
- Optimizing cloud resource usage to minimize compute and storage expenses
- Implementing intelligent scheduling that reduces API call costs
- Analyzing tool usage patterns to eliminate redundant subscriptions
- Creating ROI models that guide target selection and resource allocation

---

## Core Concepts

### Cost Categories in Bug Bounty

| Category | Examples | Typical Monthly Cost |
|----------|----------|---------------------|
| Cloud Compute | VPS for scanning, CI/CD runners | $20-200 |
| API Subscriptions | Shodan, Censys, SecurityTrails | $50-500 |
| Proxy Services | Rotating proxies, VPN | $20-100 |
| Storage | Cloud storage for results, backups | $5-50 |
| Bandwidth | Data transfer fees | $10-100 |
| Tools | Burp Suite Pro, specialized tools | $0-400 |
| Your Time | Hours spent per finding | Priceless (but track it) |

### ROI Calculation Framework

```
ROI = (Bounty Earned - Total Cost) / Total Cost x 100

Where Total Cost includes:
- Direct monetary costs (subscriptions, compute)
- Indirect costs (time x hourly rate)
- Opportunity costs (alternative activities forgone)
```

### Cost Optimization Hierarchy

1. **Eliminate**: Remove unnecessary costs entirely
2. **Reduce**: Decrease usage of necessary resources
3. **Optimize**: Improve efficiency of resources you must use
4. **Substitute**: Replace expensive options with cheaper alternatives
5. **Leverage**: Use free tiers, open-source tools, community resources

### Cost Tracking Principles

- **Attribution**: Every dollar spent should be traceable to a specific activity
- **Visibility**: Costs should be visible in real-time, not just at month-end
- **Accountability**: Each team member should understand cost implications
- **Optimization**: Regular review and optimization of cost drivers

---

## Prerequisites

### Required Knowledge
- Python data analysis (pandas, matplotlib basics)
- Cloud provider billing concepts (AWS, GCP, Azure)
- Basic understanding of API pricing models
- Time tracking and productivity measurement

### Required Tools
```bash
pip install pandas matplotlib schedule python-dotenv tabulate
```

### Cost Data Sources
- Cloud provider billing dashboards
- API usage logs from provider consoles
- Local tool usage statistics
- Time tracking applications
- Subscription management platforms

---

## Methodology

### Phase 1: Cost Discovery and Tracking

**Step 1: Build Cost Tracking System**

```python
import json
from datetime import datetime, timedelta
from pathlib import Path
from dataclasses import dataclass, asdict
from typing import List, Dict
from enum import Enum

class CostCategory(Enum):
    CLOUD_COMPUTE = "cloud_compute"
    API_SUBSCRIPTION = "api_subscription"
    PROXY_SERVICE = "proxy_service"
    STORAGE = "storage"
    BANDWIDTH = "bandwidth"
    TOOLS = "tools"
    TIME = "time"

@dataclass
class CostEntry:
    timestamp: str
    category: CostCategory
    service: str
    description: str
    amount: float
    currency: str
    project: str
    tags: Dict[str, str]

class CostTracker:
    """Track and categorize all bug bounty expenses."""

    def __init__(self, data_dir="cost_tracking"):
        self.data_dir = Path(data_dir)
        self.data_dir.mkdir(exist_ok=True)
        self.entries_file = self.data_dir / "cost_entries.json"
        self.entries = self._load_entries()

    def _load_entries(self):
        """Load existing cost entries."""
        if self.entries_file.exists():
            with open(self.entries_file) as f:
                data = json.load(f)
                return [CostEntry(**entry) for entry in data]
        return []

    def _save_entries(self):
        """Save cost entries to disk."""
        with open(self.entries_file, 'w') as f:
            json.dump([asdict(e) for e in self.entries], f, indent=2)

    def add_entry(self, category, service, description, amount,
                  currency="USD", project="general", tags=None):
        """Add a new cost entry."""
        entry = CostEntry(
            timestamp=datetime.now().isoformat(),
            category=category if isinstance(category, CostCategory)
                     else CostCategory(category),
            service=service,
            description=description,
            amount=amount,
            currency=currency,
            project=project,
            tags=tags or {}
        )

        self.entries.append(entry)
        self._save_entries()

        return entry

    def get_total_by_category(self, start_date=None, end_date=None):
        """Get total costs grouped by category."""
        filtered = self._filter_entries(start_date, end_date)

        totals = {}
        for entry in filtered:
            cat = entry.category.value
            totals[cat] = totals.get(cat, 0) + entry.amount

        return totals

    def get_total_by_service(self, start_date=None, end_date=None):
        """Get total costs grouped by service."""
        filtered = self._filter_entries(start_date, end_date)

        totals = {}
        for entry in filtered:
            totals[entry.service] = totals.get(entry.service, 0) + entry.amount

        return totals

    def get_monthly_trend(self, months=6):
        """Get monthly cost trend."""
        monthly = {}
        cutoff = datetime.now() - timedelta(days=months * 30)

        for entry in self.entries:
            entry_date = datetime.fromisoformat(entry.timestamp)
            if entry_date >= cutoff:
                month_key = entry_date.strftime("%Y-%m")
                monthly[month_key] = monthly.get(month_key, 0) + entry.amount

        return dict(sorted(monthly.items()))

    def _filter_entries(self, start_date=None, end_date=None):
        """Filter entries by date range."""
        filtered = self.entries

        if start_date:
            filtered = [
                e for e in filtered
                if datetime.fromisoformat(e.timestamp) >= start_date
            ]

        if end_date:
            filtered = [
                e for e in filtered
                if datetime.fromisoformat(e.timestamp) <= end_date
            ]

        return filtered
```

**Step 2: Usage Analytics Implementation**

```python
import time
from collections import defaultdict
from functools import wraps

class UsageAnalytics:
    """Track resource usage across all automation tools."""

    def __init__(self, data_dir="usage_analytics"):
        self.data_dir = Path(data_dir)
        self.data_dir.mkdir(exist_ok=True)
        self.usage_file = self.data_dir / "usage_data.json"
        self.usage_data = self._load_usage()
        self.active_timers = {}

    def _load_usage(self):
        if self.usage_file.exists():
            with open(self.usage_file) as f:
                return json.load(f)
        return {"api_calls": {}, "compute_seconds": {}, "storage_bytes": {}}

    def _save_usage(self):
        with open(self.usage_file, 'w') as f:
            json.dump(self.usage_data, f, indent=2)

    def track_api_call(self, service, endpoint, response_time_ms, success=True):
        """Track an API call for usage analytics."""
        today = datetime.now().strftime("%Y-%m-%d")
        key = f"{service}:{endpoint}"

        if key not in self.usage_data["api_calls"]:
            self.usage_data["api_calls"][key] = {}

        if today not in self.usage_data["api_calls"][key]:
            self.usage_data["api_calls"][key][today] = {
                "count": 0, "total_ms": 0, "errors": 0
            }

        day_data = self.usage_data["api_calls"][key][today]
        day_data["count"] += 1
        day_data["total_ms"] += response_time_ms
        if not success:
            day_data["errors"] += 1

        self._save_usage()

    def track_compute(self, task_name, duration_seconds):
        """Track compute time for a task."""
        today = datetime.now().strftime("%Y-%m-%d")
        key = task_name

        if key not in self.usage_data["compute_seconds"]:
            self.usage_data["compute_seconds"][key] = {}

        if today not in self.usage_data["compute_seconds"][key]:
            self.usage_data["compute_seconds"][key][today] = 0

        self.usage_data["compute_seconds"][key][today] += duration_seconds
        self._save_usage()

    def track_storage(self, component, bytes_used):
        """Track storage usage."""
        today = datetime.now().strftime("%Y-%m-%d")

        if today not in self.usage_data["storage_bytes"]:
            self.usage_data["storage_bytes"][today] = {}

        self.usage_data["storage_bytes"][today][component] = bytes_used
        self._save_usage()

    def get_usage_summary(self, days=30):
        """Get usage summary for the last N days."""
        cutoff = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")

        summary = {
            "api_calls": defaultdict(int),
            "compute_hours": defaultdict(float),
            "storage_gb": {}
        }

        # API calls
        for key, daily in self.usage_data["api_calls"].items():
            for date, data in daily.items():
                if date >= cutoff:
                    service = key.split(":")[0]
                    summary["api_calls"][service] += data["count"]

        # Compute
        for key, daily in self.usage_data["compute_seconds"].items():
            for date, seconds in daily.items():
                if date >= cutoff:
                    summary["compute_hours"][key] += seconds / 3600

        # Storage
        for date, components in self.usage_data["storage_bytes"].items():
            if date >= cutoff:
                for component, bytes_used in components.items():
                    summary["storage_gb"][component] = bytes_used / (1024**3)

        return dict(summary)

    def start_timer(self, task_name):
        """Start a timer for a task."""
        self.active_timers[task_name] = time.time()

    def stop_timer(self, task_name):
        """Stop a timer and record compute time."""
        if task_name in self.active_timers:
            elapsed = time.time() - self.active_timers[task_name]
            self.track_compute(task_name, elapsed)
            del self.active_timers[task_name]
            return elapsed
        return 0
```

### Phase 2: Cost Optimization Strategies

**Step 3: Intelligent Resource Scheduling**

```python
import schedule
import time as time_module
from datetime import datetime, timedelta

class CostAwareScheduler:
    """Schedule tasks to minimize costs."""

    def __init__(self, cost_tracker, analytics):
        self.cost_tracker = cost_tracker
        self.analytics = analytics
        self.peak_hours = list(range(9, 18))  # 9 AM - 6 PM
        self.off_peak_discount = 0.5  # 50% cheaper off-peak

    def is_off_peak(self):
        """Check if current time is off-peak (cheaper)."""
        current_hour = datetime.now().hour
        return current_hour not in self.peak_hours

    def calculate_task_cost(self, task_type, estimated_duration_hours):
        """Estimate cost of running a task."""
        cost_per_hour = {
            "scanning": 0.10,
            "crawling": 0.05,
            "api_heavy": 0.20,
            "analysis": 0.08,
        }

        base_cost = cost_per_hour.get(task_type, 0.10) * estimated_duration_hours

        if self.is_off_peak():
            return base_cost * self.off_peak_discount
        return base_cost

    def schedule_cost_optimized(self, task_name, task_type, func,
                                 estimated_duration_hours, deadline=None):
        """Schedule a task at the cheapest possible time."""
        now = datetime.now()

        # Check if off-peak now
        if self.is_off_peak():
            print(f"Running {task_name} now (off-peak pricing)")
            return func()

        # Calculate next off-peak window
        current_hour = now.hour
        if current_hour < 18:
            hours_until_offpeak = 18 - current_hour
        else:
            hours_until_offpeak = (24 - current_hour) + 6  # Tomorrow 6 AM

        # Check deadline
        if deadline:
            time_until_deadline = (deadline - now).total_seconds() / 3600
            if time_until_deadline < hours_until_offpeak:
                print(f"Deadline approaching. Running {task_name} at peak cost.")
                return func()

        scheduled_time = now + timedelta(hours=hours_until_offpeak)
        print(f"Scheduling {task_name} for {scheduled_time} (off-peak)")

        # In production, use a job scheduler
        # This is a simplified version
        return {"scheduled": scheduled_time.isoformat(), "task": task_name}

    def get_optimization_recommendations(self):
        """Generate cost optimization recommendations."""
        recommendations = []
        usage = self.analytics.get_usage_summary(days=30)

        # Check for high API usage
        for service, calls in usage["api_calls"].items():
            if calls > 10000:
                recommendations.append({
                    "type": "api_optimization",
                    "service": service,
                    "current_calls": calls,
                    "suggestion": "Implement caching to reduce API calls",
                    "estimated_savings": f"{calls * 0.001:.2f} USD/month"
                })

        # Check for excessive compute
        for task, hours in usage["compute_hours"].items():
            if hours > 100:
                recommendations.append({
                    "type": "compute_optimization",
                    "task": task,
                    "current_hours": hours,
                    "suggestion": "Run during off-peak hours for 50% discount",
                    "estimated_savings": f"{hours * 0.05:.2f} USD/month"
                })

        return recommendations
```

**Step 4: Subscription and Tool Optimization**

```python
class SubscriptionOptimizer:
    """Analyze and optimize tool subscriptions."""

    def __init__(self, cost_tracker):
        self.cost_tracker = cost_tracker

    def analyze_subscription_value(self, service_name, monthly_cost,
                                    bounties_from_service):
        """Calculate ROI for a specific subscription."""
        annual_cost = monthly_cost * 12
        annual_bounty_value = bounties_from_service * 12

        if annual_cost == 0:
            return {"service": service_name, "roi": float("inf")}

        roi = ((annual_bounty_value - annual_cost) / annual_cost) * 100

        return {
            "service": service_name,
            "monthly_cost": monthly_cost,
            "monthly_bounty_value": bounties_from_service,
            "annual_cost": annual_cost,
            "annual_bounty_value": annual_bounty_value,
            "roi_percent": roi,
            "recommendation": self._get_recommendation(roi)
        }

    def _get_recommendation(self, roi):
        if roi > 500:
            return "KEEP - Excellent ROI"
        elif roi > 200:
            return "KEEP - Good ROI"
        elif roi > 0:
            return "REVIEW - Marginal ROI, optimize usage"
        else:
            return "CANCEL - Negative ROI"

    def find_alternatives(self, current_tools):
        """Suggest free or cheaper alternatives."""
        alternatives_db = {
            "shodan_paid": [
                {"name": "shodan_free", "cost": 0, "limitations": "100 results/query"},
                {"name": "censys_free", "cost": 0, "limitations": "250 queries/month"}
            ],
            "burp_pro": [
                {"name": "burp_community", "cost": 0, "limitations": "Manual scanning only"},
                {"name": "owasp_zap", "cost": 0, "limitations": "Less automation"}
            ],
            "vpn_paid": [
                {"name": "tor", "cost": 0, "limitations": "Slower speeds"},
                {"name": "windscribe_free", "cost": 0, "limitations": "10GB/month"}
            ],
        }

        suggestions = []
        for tool in current_tools:
            if tool in alternatives_db:
                suggestions.extend(alternatives_db[tool])

        return suggestions

    def generate_cost_report(self):
        """Generate comprehensive cost analysis report."""
        monthly_costs = self.cost_tracker.get_monthly_trend(months=3)

        report = {
            "current_monthly_cost": sum(monthly_costs.values()) / max(len(monthly_costs), 1),
            "monthly_trend": monthly_costs,
            "cost_by_category": self.cost_tracker.get_total_by_category(),
            "cost_by_service": self.cost_tracker.get_total_by_service(),
            "optimization_opportunities": []
        }

        # Identify highest cost items
        by_service = report["cost_by_service"]
        sorted_services = sorted(by_service.items(), key=lambda x: x[1], reverse=True)

        for service, cost in sorted_services[:5]:
            report["optimization_opportunities"].append({
                "service": service,
                "current_cost": cost,
                "action": "Review usage and optimize"
            })

        return report
```

### Phase 3: ROI Analysis and Target Selection

**Step 5: ROI-Based Target Scoring**

```python
class TargetROIAnalyzer:
    """Analyze ROI for different bounty targets."""

    def __init__(self):
        self.target_data = {}

    def add_target(self, target_name, program_type, avg_bounty,
                   difficulty_estimate, time_estimate_hours,
                   success_probability):
        """Add a target for ROI analysis."""
        self.target_data[target_name] = {
            "program_type": program_type,
            "avg_bounty": avg_bounty,
            "difficulty": difficulty_estimate,
            "time_hours": time_estimate_hours,
            "success_prob": success_probability
        }

    def calculate_target_roi(self, target_name, hourly_rate=50,
                              cost_per_hour=10):
        """Calculate expected ROI for a target."""
        if target_name not in self.target_data:
            raise ValueError(f"Target not found: {target_name}")

        target = self.target_data[target_name]

        # Costs
        time_cost = target["time_hours"] * hourly_rate
        tool_cost = target["time_hours"] * cost_per_hour
        total_cost = time_cost + tool_cost

        # Expected value
        expected_bounty = target["avg_bounty"] * target["success_prob"]

        # ROI
        if total_cost == 0:
            roi = float("inf")
        else:
            roi = ((expected_bounty - total_cost) / total_cost) * 100

        return {
            "target": target_name,
            "expected_bounty": expected_bounty,
            "total_cost": total_cost,
            "roi_percent": roi,
            "break_even_probability": total_cost / target["avg_bounty"]
        }

    def rank_targets(self, hourly_rate=50, cost_per_hour=10):
        """Rank targets by expected ROI."""
        rankings = []

        for target_name in self.target_data:
            roi_data = self.calculate_target_roi(
                target_name, hourly_rate, cost_per_hour
            )
            rankings.append(roi_data)

        # Sort by ROI descending
        rankings.sort(key=lambda x: x["roi_percent"], reverse=True)

        return rankings

    def optimize_portfolio(self, total_hours_available, hourly_rate=50,
                           cost_per_hour=10):
        """Optimize target portfolio for available time."""
        ranked = self.rank_targets(hourly_rate, cost_per_hour)

        portfolio = []
        remaining_hours = total_hours_available
        total_expected_value = 0
        total_cost = 0

        for target in ranked:
            target_info = self.target_data[target["target"]]
            hours_needed = target_info["time_hours"]

            if hours_needed <= remaining_hours:
                portfolio.append({
                    "target": target["target"],
                    "hours": hours_needed,
                    "expected_value": target["expected_bounty"],
                    "cost": hours_needed * (hourly_rate + cost_per_hour)
                })
                remaining_hours -= hours_needed
                total_expected_value += target["expected_bounty"]
                total_cost += hours_needed * (hourly_rate + cost_per_hour)

        portfolio_roi = (
            (total_expected_value - total_cost) / total_cost * 100
            if total_cost > 0 else 0
        )

        return {
            "portfolio": portfolio,
            "total_hours": total_hours_available,
            "hours_used": total_hours_available - remaining_hours,
            "total_expected_value": total_expected_value,
            "total_cost": total_cost,
            "portfolio_roi": portfolio_roi
        }
```

---

## Tool Arsenal

### Cost Monitoring Dashboard

```python
from rich.console import Console
from rich.table import Table
from rich.panel import Panel

def cost_dashboard(cost_tracker):
    """Display real-time cost monitoring dashboard."""
    console = Console()

    # Header
    console.print(Panel("Bug Bounty Cost Dashboard", style="bold green"))

    # Monthly costs
    monthly = cost_tracker.get_monthly_trend(months=3)
    table = Table(title="Monthly Cost Trend")
    table.add_column("Month", style="cyan")
    table.add_column("Cost", style="yellow")
    table.add_column("Trend", style="green")

    prev_cost = None
    for month, cost in monthly.items():
        if prev_cost:
            trend = ((cost - prev_cost) / prev_cost) * 100
            trend_str = f"+{trend:.1f}%" if trend > 0 else f"{trend:.1f}%"
        else:
            trend_str = "N/A"
        table.add_row(month, f"${cost:.2f}", trend_str)
        prev_cost = cost

    console.print(table)

    # By category
    by_category = cost_tracker.get_total_by_category()
    cat_table = Table(title="Cost by Category")
    cat_table.add_column("Category", style="cyan")
    cat_table.add_column("Amount", style="yellow")
    cat_table.add_column("Percentage", style="green")

    total = sum(by_category.values())
    for cat, amount in sorted(by_category.items(), key=lambda x: x[1], reverse=True):
        pct = (amount / total * 100) if total > 0 else 0
        cat_table.add_row(cat, f"${amount:.2f}", f"{pct:.1f}%")

    console.print(cat_table)

    # Optimization suggestions
    console.print("\n[bold]Optimization Opportunities:[/bold]")
    console.print("  1. Review API-heavy services for caching opportunities")
    console.print("  2. Shift compute tasks to off-peak hours")
    console.print("  3. Evaluate free alternatives for low-usage tools")
```

### Automated Cost Alerts

```python
class CostAlerting:
    """Automated cost alerting system."""

    def __init__(self, cost_tracker, monthly_budget):
        self.cost_tracker = cost_tracker
        self.monthly_budget = monthly_budget
        self.alert_thresholds = [50, 75, 90, 100]  # Percentage of budget

    def check_budget_status(self):
        """Check current spending against budget."""
        current_month = datetime.now().strftime("%Y-%m")
        monthly_costs = self.cost_tracker.get_monthly_trend(months=1)

        current_spend = monthly_costs.get(current_month, 0)
        budget_percentage = (current_spend / self.monthly_budget) * 100

        status = {
            "current_spend": current_spend,
            "budget": self.monthly_budget,
            "percentage": budget_percentage,
            "remaining": self.monthly_budget - current_spend,
            "days_left_in_month": self._days_left_in_month(),
            "projected_total": self._project_monthly_total(current_spend),
            "alerts": []
        }

        # Check thresholds
        for threshold in self.alert_thresholds:
            if budget_percentage >= threshold:
                status["alerts"].append({
                    "threshold": threshold,
                    "triggered": True,
                    "message": f"Budget at {budget_percentage:.1f}% "
                              f"(${current_spend:.2f}/${self.monthly_budget:.2f})"
                })

        # Projected over budget warning
        if status["projected_total"] > self.monthly_budget:
            status["alerts"].append({
                "threshold": 100,
                "triggered": True,
                "message": f"Projected to exceed budget: "
                          f"${status['projected_total']:.2f}"
            })

        return status

    def _days_left_in_month(self):
        today = datetime.now()
        if today.month == 12:
            next_month = today.replace(year=today.year + 1, month=1, day=1)
        else:
            next_month = today.replace(month=today.month + 1, day=1)
        return (next_month - today).days

    def _project_monthly_total(self, current_spend):
        today = datetime.now()
        day_of_month = today.day
        days_in_month = 30  # Average

        if day_of_month > 0:
            daily_rate = current_spend / day_of_month
            return daily_rate * days_in_month
        return current_spend
```

### Cost Visualization

```python
def create_cost_charts(cost_tracker, output_dir="cost_reports"):
    """Generate cost visualization charts."""
    import matplotlib
    matplotlib.use('Agg')  # Non-interactive backend
    import matplotlib.pyplot as plt
    from collections import defaultdict

    output_path = Path(output_dir)
    output_path.mkdir(exist_ok=True)

    # Monthly trend chart
    monthly = cost_tracker.get_monthly_trend(months=6)

    fig, ax = plt.subplots(figsize=(10, 6))
    months = list(monthly.keys())
    costs = list(monthly.values())

    ax.bar(months, costs, color='steelblue')
    ax.set_xlabel('Month')
    ax.set_ylabel('Cost (USD)')
    ax.set_title('Monthly Cost Trend')
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig(output_path / "monthly_trend.png")
    plt.close()

    # Category breakdown pie chart
    by_category = cost_tracker.get_total_by_category()

    fig, ax = plt.subplots(figsize=(8, 8))
    labels = list(by_category.keys())
    sizes = list(by_category.values())
    colors = plt.cm.Set3(range(len(labels)))

    ax.pie(sizes, labels=labels, colors=colors, autopct='%1.1f%%')
    ax.set_title('Cost Distribution by Category')
    plt.tight_layout()
    plt.savefig(output_path / "category_breakdown.png")
    plt.close()

    return {
        "monthly_trend": str(output_path / "monthly_trend.png"),
        "category_breakdown": str(output_path / "category_breakdown.png")
    }
```

---

## Real-World Examples

### Example 1: API Cost Optimization

**Scenario**: Spending $200/month on Shodan API for reconnaissance.

```python
def optimize_shodan_costs(api_key, monthly_budget=50):
    """Optimize Shodan API usage to reduce costs."""
    import requests

    class ShodanOptimizer:
        def __init__(self, api_key):
            self.api_key = api_key
            self.cache = {}
            self.call_count = 0

        def cached_search(self, query):
            """Cache results to avoid duplicate API calls."""
            if query in self.cache:
                return self.cache[query]

            # Only call API if not cached
            url = f"https://api.shodan.io/shodan/host/search?key={self.api_key}&query={query}"
            response = requests.get(url)

            if response.status_code == 200:
                self.cache[query] = response.json()
                self.call_count += 1

            return self.cache.get(query)

        def batch_queries(self, queries):
            """Combine multiple queries to reduce API calls."""
            # Instead of 10 separate queries, use one combined query
            combined = " OR ".join(queries)
            return self.cached_search(combined)

        def get_usage_report(self):
            return {
                "cached_results": len(self.cache),
                "api_calls_made": self.call_count,
                "estimated_cost": self.call_count * 0.005  # Shodan pricing
            }

    optimizer = ShodanOptimizer(api_key)

    # Example usage
    queries = [
        "org:target company",
        "ssl.cert.subject.cn:target.com",
        "hostname:*.target.com"
    ]

    results = optimizer.batch_queries(queries)
    report = optimizer.get_usage_report()

    print(f"API calls saved: {len(queries) - 1}")
    print(f"Estimated cost: ${report['estimated_cost']:.2f}")

    return report
```

### Example 2: Cloud Compute Cost Reduction

```python
def optimize_cloud_compute():
    """Strategies for reducing cloud compute costs."""

    strategies = {
        "spot_instances": {
            "description": "Use spot/preemptible instances for scanning",
            "savings": "60-90% vs on-demand",
            "implementation": """
                # AWS Spot Instance example
                import boto3

                ec2 = boto3.client('ec2')
                response = ec2.request_spot_instances(
                    SpotPrice='0.01',
                    InstanceCount=1,
                    LaunchSpecification={
                        'ImageId': 'ami-xxxxx',
                        'InstanceType': 't3.medium',
                        # ... other config
                    }
                )
            """
        },
        "scheduled_scaling": {
            "description": "Scale down during non-working hours",
            "savings": "40-60%",
            "implementation": """
                # Schedule auto-scaling
                import schedule

                def scale_down():
                    # Scale to minimum instances
                    pass

                def scale_up():
                    # Scale to working capacity
                    pass

                schedule.every().day.at("22:00").do(scale_down)
                schedule.every().day.at("08:00").do(scale_up)
            """
        },
        "right_sizing": {
            "description": "Match instance size to actual workload",
            "savings": "20-40%",
            "implementation": """
                # Monitor and recommend right-sizing
                def analyze_utilization(cloud_provider):
                    metrics = cloud_provider.get_metrics('cpu', 'memory')
                    
                    recommendations = []
                    if metrics['cpu_avg'] < 20:
                        recommendations.append("Consider smaller instance")
                    if metrics['memory_avg'] < 30:
                        recommendations.append("Reduce memory allocation")
                    
                    return recommendations
            """
        }
    }

    return strategies
```

### Example 3: Tool Subscription Audit

```python
def audit_tool_subscriptions():
    """Audit and optimize tool subscriptions."""

    current_subscriptions = [
        {"name": "Burp Suite Pro", "monthly": 44, "usage": "daily", "value": "high"},
        {"name": "Shodan", "monthly": 49, "usage": "weekly", "value": "medium"},
        {"name": "Censys", "monthly": 59, "usage": "monthly", "value": "low"},
        {"name": "VPN Service", "monthly": 12, "usage": "daily", "value": "high"},
        {"name": "Proxy Service", "monthly": 30, "usage": "weekly", "value": "medium"},
    ]

    audit_results = []
    total_monthly = 0

    for sub in current_subscriptions:
        # Calculate cost per use
        usage_frequency = {
            "daily": 30,
            "weekly": 4,
            "monthly": 1
        }

        monthly_uses = usage_frequency.get(sub["usage"], 1)
        cost_per_use = sub["monthly"] / monthly_uses

        # Determine recommendation
        if sub["value"] == "low" and cost_per_use > 10:
            recommendation = "CANCEL - Consider free alternative"
        elif sub["value"] == "medium" and cost_per_use > 5:
            recommendation = "REVIEW - Usage may not justify cost"
        else:
            recommendation = "KEEP - Good value"

        audit_results.append({
            "name": sub["name"],
            "monthly_cost": sub["monthly"],
            "cost_per_use": cost_per_use,
            "value_rating": sub["value"],
            "recommendation": recommendation
        })

        total_monthly += sub["monthly"]

    # Potential savings
    cancellable = sum(
        r["monthly_cost"] for r in audit_results
        if "CANCEL" in r["recommendation"]
    )

    return {
        "current_total_monthly": total_monthly,
        "current_total_annual": total_monthly * 12,
        "potential_monthly_savings": cancellable,
        "potential_annual_savings": cancellable * 12,
        "recommendations": audit_results
    }
```

---

## Common Pitfalls

### Pitfall 1: Tracking Only Direct Costs
Don't forget to account for your time, opportunity costs, and indirect expenses like electricity or internet.

### Pitfall 2: Ignoring Free Tiers
Many API services offer generous free tiers that are sufficient for individual researchers. Always evaluate free options first.

### Pitfall 3: Over-Provisioning Resources
Using a VPS with 16GB RAM when your scans only need 2GB wastes money. Right-size your infrastructure.

### Pitfall 4: Not Monitoring API Usage
API costs can spiral quickly without monitoring. Set up alerts and quotas.

### Pitfall 5: Manual Cost Tracking
Spreadsheets become outdated quickly. Automate cost tracking from the beginning.

### Pitfall 6: Ignoring Caching
Cache API responses and scan results to avoid redundant expensive operations.

### Pitfall 7: No Budget Limits
Set hard budget limits and alerts to prevent unexpected cost overruns.

---

## Advanced Techniques

### Predictive Cost Modeling

```python
def build_cost_predictor(historical_data):
    """Build a predictive model for future costs."""
    import pandas as pd
    from sklearn.linear_model import LinearRegression

    # Convert to DataFrame
    df = pd.DataFrame(historical_data)
    df['month_num'] = range(len(df))

    # Simple linear regression
    X = df[['month_num']]
    y = df['cost']

    model = LinearRegression()
    model.fit(X, y)

    # Predict next 3 months
    future_months = [[len(df)], [len(df) + 1], [len(df) + 2]]
    predictions = model.predict(future_months)

    return {
        "model": model,
        "predictions": predictions.tolist(),
        "trend": "increasing" if model.coef_[0] > 0 else "decreasing",
        "monthly_change": model.coef_[0]
    }
```

### Cost Allocation Across Projects

```python
class CostAllocator:
    """Allocate costs across multiple bounty programs."""

    def __init__(self, cost_tracker):
        self.cost_tracker = cost_tracker

    def allocate_by_time(self, time_entries):
        """Allocate costs based on time spent per project."""
        total_time = sum(entry["hours"] for entry in time_entries)

        allocations = {}
        for entry in time_entries:
            project = entry["project"]
            proportion = entry["hours"] / total_time

            allocated_cost = proportion * self._get_total_cost()
            allocations[project] = allocations.get(project, 0) + allocated_cost

        return allocations

    def allocate_by_api_calls(self, api_logs):
        """Allocate costs based on API usage per project."""
        total_calls = sum(log["calls"] for log in api_logs)

        allocations = {}
        for log in api_logs:
            project = log["project"]
            proportion = log["calls"] / total_calls

            allocated_cost = proportion * self._get_api_cost()
            allocations[project] = allocations.get(project, 0) + allocated_cost

        return allocations

    def _get_total_cost(self):
        by_category = self.cost_tracker.get_total_by_category()
        return sum(by_category.values())

    def _get_api_cost(self):
        by_category = self.cost_tracker.get_total_by_category()
        return by_category.get("api_subscription", 0)
```

---

## Reporting Template

### Monthly Cost Report

```markdown
## Monthly Cost Report - [Month Year]

**Report Date**: [Date]
**Period**: [Start Date] to [End Date]

### Summary
| Metric | Value |
|--------|-------|
| Total Spend | $[Amount] |
| Budget | $[Amount] |
| Variance | [+/-$Amount] ([+/-Percent]%) |
| Projected Month-End | $[Amount] |

### Cost Breakdown
| Category | Amount | % of Total | vs Last Month |
|----------|--------|------------|---------------|
| Cloud Compute | $[Amount] | [Percent]% | [+/-$Amount] |
| API Subscriptions | $[Amount] | [Percent]% | [+/-$Amount] |
| Tools | $[Amount] | [Percent]% | [+/-$Amount] |
| Other | $[Amount] | [Percent]% | [+/-$Amount] |

### ROI Analysis
| Program | Time Invested | Bounties Earned | ROI |
|---------|---------------|-----------------|-----|
| [Program] | [Hours] | $[Amount] | [Percent]% |

### Optimization Actions Taken
1. [Action 1] - Saved $[Amount]
2. [Action 2] - Saved $[Amount]

### Recommendations for Next Month
1. [Recommendation 1]
2. [Recommendation 2]
```

---

## Quick Reference

### Cost Optimization Checklist
- [ ] All costs tracked and categorized
- [ ] Monthly budget set and monitored
- [ ] API caching implemented
- [ ] Off-peak scheduling configured
- [ ] Subscriptions audited quarterly
- [ ] Free alternatives evaluated
- [ ] Right-sizing reviewed monthly
- [ ] Cost alerts configured

### ROI Quick Formula
```
ROI = (Bounty - Cost) / Cost x 100

Break-even = Cost / Avg Bounty
```

### Cost Reduction Strategies
| Strategy | Potential Savings | Effort |
|----------|-------------------|--------|
| API caching | 30-50% | Medium |
| Off-peak scheduling | 40-60% | Low |
| Spot instances | 60-90% | Medium |
| Subscription audit | 20-40% | Low |
| Tool consolidation | 15-30% | High |

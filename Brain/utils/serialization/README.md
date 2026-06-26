# Data Serialization

## Overview

The `utils/serialization` module handles conversion between Python objects and wire/storage formats with support for type preservation, compression, and format auto-detection.

## Serializer Class

```python
from Brain.utils.serialization import Serializer

serializer = Serializer(default_format="json")
data = serializer.encode({"key": "value", "count": 42})
obj = serializer.decode(data)
```

### Initialization

```python
Serializer(
    default_format: str = "json",       # Fallback format for encode()
    compression: str = None,             # "gzip" | "zlib" | None
    compression_threshold: int = 1024,   # Min bytes before compressing
    type_preserving: bool = True,        # Preserve Python types through round-trip
    custom_encoders: dict = None,        # {type: encoder_func} overrides
    custom_decoders: dict = None         # {type_tag: decoder_func} overrides
)
```

## Supported Formats

### JSON

```python
serializer = Serializer(default_format="json")

encoded = serializer.encode({"users": [1, 2, 3]}, format="json")
decoded = serializer.decode(encoded, format="json")
```

Built-in options:
- `indent: int = None` — pretty-print with N spaces
- `sort_keys: bool = False` — deterministic key ordering
- `default: str = "strict"` — "strict" raises on non-serializable, "fallback" uses str()

### YAML

```python
encoded = serializer.encode(config, format="yaml")
# Produces readable YAML with proper indentation

decoded = serializer.decode(encoded, format="yaml")
```

Requires `pyyaml`. Supports anchors, multi-line strings, and comments through custom dumper options.

### MessagePack

```python
encoded = serializer.encode(large_payload, format="msgpack")
# Compact binary format, ~30-50% smaller than JSON for typical data

decoded = serializer.decode(encoded, format="msgpack")
```

Requires `msgpack`. Ideal for inter-service communication and caching where size matters.

### Protocol Buffers

```python
from Brain.utils.serialization import ProtoSerializer

proto = ProtoSerializer(schema_path="schemas/user.proto")
encoded = proto.encode("User", user_object)
decoded = proto.decode("User", encoded)
```

Requires `protobuf`. Provides schema-enforced encoding with field-level validation.

## Compression

Apply transparent compression to serialized data:

```python
# Auto-compress above threshold
serializer = Serializer(compression="gzip", compression_threshold=512)
encoded = serializer.encode(large_dict)  # compressed if > 512 bytes

# Manual compression
compressed = serializer.compress(raw_bytes, format="gzip")
decompressed = serializer.decompress(compressed, format="gzip")
```

### Supported Algorithms

| Algorithm | Speed  | Ratio  | When to Use |
|-----------|--------|--------|-------------|
| `gzip`    | Medium | Good   | General purpose, widely supported |
| `zlib`    | Fast   | Medium | High-throughput internal storage |

Compression is transparent during decode — the format is auto-detected from the binary header.

## Type Preservation

Python types that don't map 1:1 to JSON are preserved through tagged wrappers:

```python
from Brain.utils.serialization import TypePreservingSerializer

ts = TypePreservingSerializer()

# Round-trips these types correctly:
original = {
    "timestamp": datetime(2026, 6, 25, 14, 30, 0, tzinfo=UTC),
    "amount": Decimal("99.95"),
    "uuid_val": UUID("123e4567-e89b-12d3-a456-426614174000"),
    "binary": b"\x00\x01\x02",
    "set_val": {1, 2, 3}
}

encoded = ts.encode(original)
decoded = ts.decode(encoded)
# decoded == original  (all types preserved)
```

### Type Tags

Encoded form wraps non-native types:
```json
{"$type": "datetime", "$value": "2026-06-25T14:30:00Z"}
{"$type": "decimal", "$value": "99.95"}
{"$type": "uuid", "$value": "123e4567-e89b-12d3-a456-426614174000"}
{"$type": "bytes", "$value": "AAEC"}
```

## Custom Serializers

Extend with your own types:

```python
from Brain.utils.serialization import Serializer, register_encoder

class Color:
    def __init__(self, r, g, b):
        self.r, self.g, self.b = r, g, b

@register_encoder(Color)
def encode_color(obj: Color) -> dict:
    return {"$type": "color", "r": obj.r, "g": obj.g, "b": obj.b}

def decode_color(data: dict) -> Color:
    return Color(data["r"], data["g"], data["b"])

serializer = Serializer(custom_decoders={"color": decode_color})
```

### Inline Registration

```python
serializer.register_encoder(datetime, lambda obj: {"$type": "datetime", "$value": obj.isoformat()})
serializer.register_decoder("datetime", lambda data: datetime.fromisoformat(data["$value"]))
```

## Format Detection

Auto-detect format from content:

```python
from Brain.utils.serialization import detect_format

detect_format(b'{"key": "value"}')         # "json"
detect_format(b'---\nkey: value\n')         # "yaml"
detect_format(b'\x1f\x8b\x08\x00...')     # "gzip" (compressed JSON)
detect_format(b'\x94\xa5key\xa5value...')  # "msgpack"

# Use in decode
result = serializer.decode(data)  # format auto-detected
result = serializer.decode(data, format="json")  # explicit override
```

### Detection Heuristics

1. **Magic bytes** — gzip (`0x1f 0x8b`), zlib (`0x78`), msgpack (`0x90-0x9f`, `0xdc`, `0xdd`)
2. **Content inspection** — `{` or `[` prefix → JSON, `---` prefix → YAML
3. **Fallback** — default to JSON if ambiguous

## Batch Operations

Serialize lists and streams efficiently:

```python
# Batch encode/decode
objects = [{"id": i, "name": f"item_{i}"} for i in range(1000)]
batch_encoded = serializer.encode_batch(objects, format="msgpack")
batch_decoded = serializer.decode_batch(batch_encoded)

# Streaming (memory-efficient for large datasets)
for chunk in serializer.stream_encode(huge_iterator(), format="jsonl"):
    write_to_file(chunk)
```

## Configuration Example

```python
from Brain.utils.serialization import Serializer
from Brain.utils.serialization.compressors import GzipCompressor

serializer = Serializer(
    default_format="json",
    compression="gzip",
    compression_threshold=2048,
    type_preserving=True,
    custom_encoders={MyType: encode_my_type},
    custom_decoders={"my_type": decode_my_type}
)

# Round-trip any supported format
wire_data = serializer.encode(response, format="msgpack")
storage_data = serializer.encode(config, format="yaml")
api_data = serializer.encode(payload, format="json")
```

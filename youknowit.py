#!/usr/bin/env python3

from base64 import b64decode
from hashlib import sha256
from hkdf import Hkdf
from Crypto.Cipher import AES


def derive_key(salt: bytes, info: bytes, length: int = 32) -> bytes:
    """Derives a key using HKDF."""
    hkdf = Hkdf(salt, info, hash=sha256)
    return hkdf.expand(b"HKEN", length)


def decrypt_data(encoded_data: str, key: bytes, iv: bytes) -> bytes:
    """Decrypts base64-encoded data using AES CBC."""
    cipher = AES.new(key, AES.MODE_CBC, iv)
    return cipher.decrypt(b64decode(encoded_data))


def parse_payload(payload: bytes):
    """Parses the decrypted payload into its components."""
    random = payload[0:8]
    venue_id = payload[8:16]
    group_id = payload[16:24]
    in_ts = int(payload[24:37])
    out_ts = int(payload[37:50])
    data = b64decode(payload[50:])

    return random, venue_id, group_id, in_ts, out_ts, data


def main():
    key_data = ""  # <-- Replace with your base64-encoded encrypted string
    key_interval = 0  # <-- Replace with your actual interval value

    salt = b""
    info = str(key_interval).encode()
    key = derive_key(salt, info)
    iv = b"0" * 16

    decrypted_payload = decrypt_data(key_data, key, iv)
    random, venue_id, group_id, in_ts, out_ts, data = parse_payload(decrypted_payload)

    print("Random:", random)
    print("Venue ID:", venue_id)
    print("Group ID:", group_id)
    print("In Timestamp:", in_ts)
    print("Out Timestamp:", out_ts)
    print("Data:", data)


if __name__ == "__main__":
    main()

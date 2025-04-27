import cv2
import os
import re
import numpy as np
from collections import defaultdict
from pathlib import Path

# === CONFIG ===
chart_folder = r"C:\Users\Abdul\Downloads\New folder (4)"
chart_file = "color_chart.txt"

# === Step 1: Build color chart from image samples ===
def extract_hsv_from_image(image_path):
    img = cv2.imread(image_path)
    img_hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    avg_hsv = cv2.mean(img_hsv)[:3]
    return np.array(avg_hsv, dtype=np.float32)

# Regex pattern to extract biomarker and value (e.g., "glucose250" → glucose, 250)
pattern = re.compile(r"([a-zA-Z]+)(\d+(?:\.\d+)?)")

color_chart = defaultdict(list)

for file in Path(chart_folder).glob("*.jpg"):
    name = file.stem  # filename without extension
    match = pattern.search(name)
    if not match:
        continue
    biomarker, value = match.groups()
    hsv_val = extract_hsv_from_image(str(file))
    color_chart[biomarker.lower()].append((hsv_val, value))

# === Save color chart to file ===
with open(chart_file, "w") as f:
    for biomarker, entries in color_chart.items():
        for hsv, val in entries:
            f.write(f"{biomarker},{val},{hsv[0]:.2f},{hsv[1]:.2f},{hsv[2]:.2f}\n")

# === Load color chart from file for inference ===
def load_chart_from_file(filepath):
    chart = defaultdict(list)
    with open(filepath, "r") as f:
        for line in f:
            biomarker, val, h, s, v = line.strip().split(",")
            hsv = np.array([float(h), float(s), float(v)], dtype=np.float32)
            chart[biomarker].append((hsv, val))
    return chart

color_chart = load_chart_from_file(chart_file)

# === Step 2: Match new HSV to closest in chart ===
def match_to_chart(input_hsv, biomarker):
    matches = color_chart.get(biomarker.lower(), [])
    if not matches:
        return "Unknown"
    distances = [np.linalg.norm(input_hsv - ref_hsv) for ref_hsv, _ in matches]
    closest_index = np.argmin(distances)
    return matches[closest_index][1]

# === Example Usage ===
hsv_input = np.array([99, 111, 154], dtype=np.float32)
biomarker = "glucose"
matched_val = match_to_chart(hsv_input, biomarker)

print(f"Input HSV: {hsv_input} → Closest match in '{biomarker}': {matched_val}")

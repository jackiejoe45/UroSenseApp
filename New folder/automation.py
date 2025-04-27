import os
import cv2
import csv
import re
from collections import defaultdict

def clean_value(raw_value):
    # Remove non-digit/decimal characters from end (e.g. '300a' -> '300')
    value = re.match(r'^[\d.]+', raw_value)
    return value.group(0) if value else raw_value

def extract_pixel_values(image_folder='images_processed'):
    os.makedirs('pixel_data', exist_ok=True)
    biomarker_files = defaultdict(list)

    image_files = [f for f in os.listdir(image_folder) if f.lower().endswith(('.jpeg', '.jpg'))]

    for filename in image_files:
        name = filename.rsplit('.', 1)[0]
        name = re.sub(r'\s*\(.*?\)', '', name)  # Remove text in parentheses e.g., (2)
        
        match = re.match(r'([a-zA-Z]+)_?([\d.]+[a-zA-Z]*)', name)
        if match:
            biomarker = match.group(1).lower()
            raw_value = match.group(2)
            value = clean_value(raw_value)
            biomarker_files[biomarker].append((filename, value))
        else:
            print(f"Skipping {filename} - unrecognized format")

    for biomarker, file_list in biomarker_files.items():
        output_filename = os.path.join('pixel_data', f'{biomarker}.csv')
        write_headers = True

        for filename, value in file_list:
            image_path = os.path.join(image_folder, filename)
            if not os.path.exists(image_path):
                print(f"Missing file: {image_path}")
                continue

            image = cv2.imread(image_path)
            if image is None:
                print(f"Unreadable image: {filename}")
                continue

            hsv_image = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)

            with open(output_filename, 'a', newline='') as csvfile:
                writer = csv.writer(csvfile)
                if write_headers:
                    writer.writerow(['h', 's', 'v', 'value'])
                    write_headers = False

                for y in range(hsv_image.shape[0]):
                    for x in range(hsv_image.shape[1]):
                        h, s, v = hsv_image[y, x]
                        writer.writerow([h, s, v, value])
            
            print(f"Processed {filename} for {biomarker}")
        print(f"Completed {biomarker} -> {output_filename}")

    print("All done.")

if __name__ == '__main__':
    extract_pixel_values()

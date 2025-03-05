import os
import cv2
import csv
from collections import defaultdict

def extract_pixel_values(image_folder='images_processed'):
    # Create a directory for output if it doesn't exist
    os.makedirs('pixel_data', exist_ok=True)
    
    # Dictionary to group files by biomarker
    biomarker_files = defaultdict(list)
    
    # Get list of image files
    image_files = [f for f in os.listdir(image_folder) if f.endswith('.jpeg')]
    
    # Group files by biomarker
    for filename in image_files:
        try:
            # Split filename by '_' and '.jpeg'
            parts = filename.replace('.jpeg', '').split('_')
            
            # Handle cases with different filename formats
            if len(parts) == 2:
                biomarker = parts[0]
                value = parts[1]
            elif len(parts) > 2:
                # For cases like 'ketones_15.jpeg'
                biomarker = parts[0]
                value = '_'.join(parts[1:])
            else:
                print(f"Skipping {filename} - unexpected filename format")
                continue
            
            biomarker_files[biomarker].append((filename, value))
        
        except Exception as e:
            print(f"Error processing {filename}: {e}")
    
    # Process files for each biomarker
    for biomarker, file_list in biomarker_files.items():
        # Prepare output file for this biomarker
        output_filename = os.path.join('pixel_data', f'{biomarker}.csv')
        
        # Flag to write headers only once
        write_headers = True
        
        # Process each file for this biomarker
        for filename, value in file_list:
            # Construct full image path
            image_path = os.path.join(image_folder, filename)
            
            # Verify image exists
            if not os.path.exists(image_path):
                print(f"Error: The file at {image_path} does not exist.")
                continue
            
            # Load the image
            image = cv2.imread(image_path)
            if image is None:
                print(f"Error: Failed to load the image {filename}.")
                continue
            
            # Convert the image from BGR to HSV
            hsv_image = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
            
            # Extract and save pixel values
            with open(output_filename, 'a', newline='') as csvfile:
                csvwriter = csv.writer(csvfile)
                
                # Write header only for the first file of each biomarker
                if write_headers:
                    csvwriter.writerow(['h', 's', 'v','value'])
                    write_headers = False
                
                # Iterate through pixels
                for y in range(hsv_image.shape[0]):
                    for x in range(hsv_image.shape[1]):
                        h, s, v = hsv_image[y, x]
                        csvwriter.writerow([h, s, v,value])
            
            print(f"Processed {filename} for {biomarker}")
        
        print(f"Completed extraction for {biomarker}: saved to {output_filename}")
    
    print("Pixel extraction completed. Check 'pixel_data' folder for biomarker files.")

# Run the extraction
if __name__ == '__main__':
    extract_pixel_values()
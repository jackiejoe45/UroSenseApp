import pickle
import numpy as np
import warnings

# Suppress specific warnings
warnings.filterwarnings("ignore", category=UserWarning)
warnings.filterwarnings("ignore", category=FutureWarning)

# Define the HSV values for the biomarkers
hsv_values = np.array([
    [22, 66, 228],  # Example HSV values for bilirubin
    [24, 48, 237],  # Example HSV values for blood
    [19, 89, 227],  # Example HSV values for glucose
    [24, 48, 237],  # Example HSV values for ketones
    [27, 19, 232],  # Example HSV values for leukocytes
    [24, 16, 231],  # Example HSV values for nitrite
    [25, 58, 235],  # Example HSV values for pH
    [27, 110, 223],  # Example HSV values for protein
    [24, 22, 235],  # Example HSV values for specific gravity
    [21, 114, 238]  # Example HSV values for urobilinogen
])

# List of model file paths
model_paths = [
    "machine learning/models/bilirubin_model.pkl",
    "machine learning/models/blood_model.pkl",
    "machine learning/models/glucose_model.pkl",
    "machine learning/models/ketones_model.pkl",
    "machine learning/models/leukocytes_model.pkl",
    "machine learning/models/nitrite_model.pkl",
    "machine learning/models/pH_model.pkl",
    "machine learning/models/protein_model.pkl",
    "machine learning/models/specific_gravity_model.pkl",
    "machine learning/models/urobilinogen_model.pkl"
]

# Iterate over each model and test with the corresponding HSV values
for model_path, hsv_value in zip(model_paths, hsv_values):
    # Load the model
    with open(model_path, 'rb') as file:
        model = pickle.load(file)

    # Predict using the model
    prediction = model.predict([hsv_value])

    # Print the result
    print(
        f"Model: {model_path.split('/')[-1]}, HSV: {hsv_value}, Prediction: {prediction}\n")

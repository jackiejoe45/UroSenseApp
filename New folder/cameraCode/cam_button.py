from picamera2 import Picamera2
import RPi.GPIO as GPIO
import time

# Initialize Picamera2
picam2 = Picamera2()
picam2.configure(picam2.create_still_configuration())

# GPIO Setup
BUTTON_PIN = 17  # Change to the GPIO pin you're using
GPIO.setmode(GPIO.BCM)  # Use Broadcom pin numbering
GPIO.setup(BUTTON_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)  # Enable internal pull-up resistor

def take_picture():
    filename = f"picture_{int(time.time())}.jpg"
    picam2.start()  # Start the camera
    print("Button pressed! Taking a picture...")
    time.sleep(1)  # Optional delay for stabilization
    picam2.capture_file(filename)
    picam2.stop()  # Stop the camera
    print(f"Picture saved as {filename}")

def main():
    print("Press the button to take a picture. Press Ctrl+C to exit.")
    try:
        while True:
            if GPIO.input(BUTTON_PIN) == GPIO.LOW:  # Button is pressed (active low)
                take_picture()
                time.sleep(0.5)  # Debounce delay
    except KeyboardInterrupt:
        print("\nExiting program.")
    finally:
        GPIO.cleanup()  # Cleanup GPIO on exit

if __name__ == "__main__":
    main()

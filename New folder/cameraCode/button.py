from picamera2 import Picamera2
import RPi.GPIO as GPIO
import time

# Initialize Picamera2
picam2 = Picamera2()
picam2.configure(picam2.create_still_configuration())

# GPIO Setup
BUTTON_PIN = 17  # GPIO pin connected to the button
GPIO.setmode(GPIO.BCM)  # Use Broadcom pin numbering
GPIO.setup(BUTTON_PIN, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)  # Enable internal pull-down resistor

def take_picture():
    filename = f"picture_{int(time.time())}.jpg"
    print("Starting camera...")
    picam2.start()
    print("Taking picture...")
    time.sleep(1)  # Optional delay for stabilization
    picam2.capture_file(filename)
    picam2.stop()
    print(f"Picture saved as {filename}")

def main():
    print("Press the button to take a picture. Press Ctrl+C to exit.")
    try:
        while True:
            if GPIO.input(BUTTON_PIN) == GPIO.HIGH:  # Button is pressed (active high)
                print("Button detected!")
                take_picture()
                time.sleep(0.5)  # Debounce delay
    except KeyboardInterrupt:
        print("Exiting program.")
    finally:
        GPIO.cleanup()  # Cleanup GPIO on exit

if __name__ == "__main__":
    main()

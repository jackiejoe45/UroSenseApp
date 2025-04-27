from picamera2 import Picamera2
import time

def take_picture():
    picam2 = Picamera2()
    picam2.configure(picam2.create_still_configuration())
    picam2.start()
    print("Get ready... Taking a picture in 3 seconds!")
    time.sleep(3)
    filename = f"picture_{int(time.time())}.jpg"
    picam2.capture_file(filename)
    picam2.stop()
    print(f"Picture saved as {filename}")

def main():
    print("Type 'hello' to take a picture or 'exit' to quit.")
    while True:
        command = input("Command: ").strip().lower()
        if command == "hello":
            take_picture()
        elif command == "exit":
            print("Exiting program.")
            break
        else:
            print("Invalid command. Type 'hello' to take a picture or 'exit' to quit.")

if __name__ == "__main__":
    main()

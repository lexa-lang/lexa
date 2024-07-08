import subprocess

def print_message(message):
    print(f"{'='*len(message)}\n{message}\n{'='*len(message)}")

def main():
    print_message("Running Racket simulation")
    subprocess.run("cd ../racket-artifact && racket artifact.rkt", shell=True, check=True)
    print_message("Done.")
    
if __name__ == "__main__":
    main()

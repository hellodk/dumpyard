import tkinter as tk

# Create the main window
root = tk.Tk()
root.title("My GUI")

# Create label
label = tk.Label(root, text="Hello, World!")

# Lay out label
label.pack()

# Run forever!
root.mainloop()

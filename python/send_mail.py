"""The first step is to create an SMTP object, each object is
used for connection with one server."""

import smtplib
server = smtplib.SMTP('smtp.gmail.com', 587)

# Next, log in to the server
server.login("abc@abc.com", "ghjjghgj")

# Send the mail
msg = "Testing Hello!"  # The /n separates the message from the headers
server.sendmail("abc@abc.com", "abc@abc.com", msg)

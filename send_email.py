import smtplib
import ssl

port = 587  # For starttls
smtp_server = "smtp.gmail.com"
sender_email = "abc@example.com"
receiver_email = "abc@example.com"
password = "!@#@GmailPassword"  # input("Type your password")
message = """\
Subject: Hi there

This message is sent from Python."""

context = ssl.create_default_context()
with smtplib.SMTP(smtp_server, port) as server:
    server.ehlo()  # Can be omitted
    server.starttls(context=context)
    server.ehlo()  # Can be omitted
    server.login(sender_email, password)
    server.sendmail(sender_email, receiver_email, message)

#!/bin/python
#Original scripted by Htay Aung Shein
#This script will report to relevant team via mail
import datetime
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

host_server="smpt_server"
port=25

sender_email="reporter@domain.com"

# Please edit the mail ids carefully because extra whitespace or tab may lead to failure the program. Python indentation must be follow at any conditions.
receiver_email=[
        "first.stakeholder@domain.com",
        "second.stakeholder@domain.com"

]

curr_date = (datetime.datetime.now().strftime('%Y-%m-%d %H:%M'))
with open("../htmlmail.html") as report_file:
        msg = MIMEMultipart()
        msg["From"] = sender_email
        msg["To"] = ";".join(receiver_email)
        msg["Cc"] = sender_email
        msg["Subject"] = 'CMP Campaign Total Taker Dashboard %s MMT' % curr_date
        msg.attach(MIMEText(report_file.read(),'html'))
        server = smtplib.SMTP(host_server, port)
        server.starttls()
        receiver_email.append(sender_email)
        server.sendmail(sender_email, receiver_email, msg.as_string())
        server.quit()


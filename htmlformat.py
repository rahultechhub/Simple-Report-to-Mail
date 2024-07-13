#!/usr/bin/python
#Scripted by - Htay Aung Shein
#Modified by - Htay Aung Shein
#This script will generate html file according to  result.
import datetime

curr_date=(datetime.datetime.now().strftime('%Y-%m-%d %H:%M'))

#Generator function to read data file
def fetch_line(filename):
    with open(filename, 'r') as infile:
        for line in infile:
            yield line

# Open a file to write html formated report.
with open("../htmlmail.html", "w") as f:
    #To print report table in HTML format
    def htmlTable(filePath, tFlag):
        f.write('<table border="2" border-collapse="collapse">')
        # Table headers
        f.write('<tr style="background-color:Silver">')
        column_name = [
                "Campaign",
                "Yesterday's Taker Count",
                "Today's Taker Count",
                "Yesterday's Qualifier Count",
                "Today's Qualifier Count",
        ]
        if tFlag != 1:
                [f.write("<th>{}</th>".format(column)) for column in column_name]
        else:
                column_name.append("Target Group Size")
                [f.write("<th>{}</th>".format(column)) for column in column_name]

        f.write("</tr>")

        row_count = 0
        for line in fetch_line(filePath):
            row = line.split(",")
            f.write("<tr>")
            [f.write("<td>{}</td>".format(value)) if value == row[0] else f.write('<td align="center">{}</td>'.format(value)) for value in row]
            f.write("</tr>")
            row_count += 1

        # end the table
        f.write("</table>")
        f.write("<small>{} rows</small>".format(row_count))
        f.write("<br>")

    f.write("<html>")
    f.write("<head>")
    f.write("<style>")
    f.write("table{width: 70%;border-collapse: collapse} th { background: #333;color:white;font-weight:bold;text-align:Center;}td,th{padding: 6px;border: 1x solid #ccc}")
    f.write("</style>")
    f.write("</head>")
    f.write("<body>")
    f.write("<b>Dear All</b>")
    f.write("<br><br>")
    f.write('<p><font size = "3">Please find below the Taker report %s MMT.</font></p><br>' % curr_date)

    # call table function with 0 flag for general campaign type.
    htmlTable("../result.csv", 0)

    f.write('<p><font size = "3">Please find below campaigns with target group size.</font></p><br>')

    # call table function with 1 flag for target group campaign type.
    htmlTable("../Tresult.csv", 1)

    f.write("</body>")
    f.write("<br><br>Regards,<br>CMP Team<br><br><br></body>")
    f.write("</html>")

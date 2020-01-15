import xml.dom.minidom
from requests.auth import HTTPDigestAuth
import requests

# Get list of forms
url = 'https://bohemia.systems/formList'
auth=HTTPDigestAuth('data', 'data')
x = requests.get(url, auth=auth)
xmlx = xml.dom.minidom.parseString(x.text)
xmlx_pretty = xmlx.toprettyxml()
print(xmlx_pretty)

# Get the content of a specific form
url2 = "https://bohemia.systems/formXml?formId=census"
y = requests.get(url2, auth=auth)
xmly = xml.dom.minidom.parseString(y.text)
xmly_pretty = xmly.toprettyxml()
print(xmly_pretty)

# Get the results (data) submissions for a specific form
url3 = 'https://bohemia.systems/view/submissionList?formId=recon'
z = requests.get(url3, auth=auth)
xmlz = xml.dom.minidom.parseString(z.text)
xmlz_pretty = xmlz.toprettyxml()
print(xmlz_pretty)

# Get the data for an individual submission
url4 = 'https://papu.us/view/downloadSubmission?formId=build_maragra-vector-control_1564234273[[@version=null and @uiVersion=null]/build_maragra-vector-control_1564234273[@key=uuid:2ae6ba76-39f3-41f4-b2f4-8e46e8d1bb6a]'
a = requests.get(url4, auth=auth)
xmla = xml.dom.minidom.parseString(a.text)
xmla_pretty = xmla.toprettyxml()
print(xmla_pretty)

from concurrent.futures import thread
from doctest import master
from email.mime import image
import json
import subprocess
import threading
import time
from unittest import result
from django.shortcuts import render
from django.http import HttpResponse
import requests
import re
import aria2p
import os
import uuid
import staticmap
import base64
from io import BytesIO

http_proxy = ""
https_proxy = ""
cpu_core = '16'
ram_usage = '7G'
gpt_location = 'C:\\Program Files\\snap\\bin\\gpt.exe'
snaphu_location = os.getcwd()+'\\snaphu_bin\\snaphu.exe'
self_host = 'http://127.0.0.1:8000/api_endpoint/'

asf_user = 'Admittedly_Goat'
asf_password = '3v99e3LzVBtz2f'

proxies = {
    "http": http_proxy,
    "https": https_proxy,
}

aria2 = aria2p.API(aria2p.Client(
    host="http://localhost",
    port=16800,
    secret="123456"
)
)

select_and_download_state = []  # the data downloaded from ASF api

coreg_state = {}  # structure: { timestamp: filename ... }

task_queue = []
'''
task queue is a sequence of dicts containing all GPT processes, such as coregistration, interferogram and other things.
structure of task queue:
    for coregistration:
        {
            'type': 'coregistration',
            'description': description, # master_timestamp : slave_timestamp
            'size':'', # size of coregistration image should be an empty string
            'is_completed': False,
            'is_started': False,
            'task_object':TaskObject, # the function object of the task
            'area': [x1,y1,....]
            'tiff_name': tiff_name # the final tiff name. Just give a random name is ok.
        }
    for interferogram:
      {
            'type': 'interferogram',
            'description': description, # master_timestamp : slave_timestamp
            'size':'', # size of interf image should be an empty string
            'is_completed': False,
            'is_started': False,
            'task_object':TaskObject, # the function object of the task
            'area': [x1,y1,....]
            'tiff_name': tiff_name # the final tiff name. Just give a random name is ok.
        }
    for deburst:
      {
            'type': 'deburst',
            'description': description, # master_timestamp : slave_timestamp
            'size':'', # size of interf image should be an empty string
            'is_completed': False,
            'is_started': False,
            'task_object':TaskObject, # the function object of the task
            'area': [x1,y1,....]
            'tiff_name': tiff_name # the final tiff name. Just give a random name is ok.
        }
    for TPR:
      {
            'type': 'tpr',
            'description': description, # master_timestamp : slave_timestamp
            'size':'', # size of interf image should be an empty string
            'is_completed': False,
            'is_started': False,
            'task_object':TaskObject, # the function object of the task
            'area': [x1,y1,....]
            'tiff_name': tiff_name # the final tiff name. Just give a random name is ok.
        }
    for Multilooking:
      {
            'type': 'multilooking',
            'description': description, # master_timestamp : slave_timestamp
            'size':'', # size of interf image should be an empty string
            'is_completed': False,
            'is_started': False,
            'task_object':TaskObject, # the function object of the task
            'area': [x1,y1,....]
            'tiff_name': tiff_name # the final tiff name. Just give a random name is ok.
      }
    for GPF:
      {
            'type': 'gpf',
            'description': description, # master_timestamp : slave_timestamp
            'size':'', # size of interf image should be an empty string
            'is_completed': False,
            'is_started': False,
            'task_object':TaskObject, # the function object of the task
            'area': [x1,y1,....]
            'tiff_name': tiff_name # the final tiff name. Just give a random name is ok.
      }
      for phase unwrapping:
      {
            'type': 'pu',
            'description': description, # master_timestamp : slave_timestamp
            'size':'', # size of interf image should be an empty string
            'is_completed': False,
            'is_started': False,
            'task_object':TaskObject, # the function object of the task
            'area': [x1,y1,....]
            'tiff_name': tiff_name # the final tiff name. Just give a random name is ok.
      }
      for phase to displacement:
      {
            'type': 'p2d',
            'description': description, # master_timestamp : slave_timestamp
            'size':'', # size of interf image should be an empty string
            'is_completed': False,
            'is_started': False,
            'task_object':TaskObject, # the function object of the task
            'area': [x1,y1,....]
            'tiff_name': tiff_name # the final tiff name. Just give a random name is ok.
      }
      for range doppler correction:
      {
            'type': 'rdc',
            'description': description, # master_timestamp : slave_timestamp
            'size':'', # size of interf image should be an empty string
            'is_completed': False,
            'is_started': False,
            'task_object':TaskObject, # the function object of the task
            'area': [x1,y1,....]
            'tiff_name': tiff_name # the final tiff name. Just give a random name is ok.
      }
'''


def tiff_download(request, tiff_name):
    with open('./tiffs/%s'%tiff_name, 'rb') as f:
        return HttpResponse(f, content_type='application/octet-stream')


def get_extent_by_timestamp(timestamp):
    with open('./image_extent_cache/data.json', 'r') as f:
        data = json.load(f)
        return data[timestamp]


def __task_queue_loop():
    while True:
        for i in task_queue:
            if i['is_completed'] == False and i['is_started'] == False:
                i['is_started'] = True
                i['task_object'].start()
                i['task_object'].join()
                i['is_completed'] = True
                print(task_queue)
                break
        print(task_queue)
        time.sleep(1)


threading.Thread(target=__task_queue_loop).start()


def download_add_queue(url):
    if(url.split('/')[-1].strip() in os.listdir('./download_images')):
        return
    print('downloading %s' % url)
    aria2.add(url, options={
        'http-auth-challenge': 'true', 'http-user': asf_user, 'http-passwd': asf_password, 'dir': '%s\\download_images' % os.getcwd()})
    return


def get_all_download(request):
    downloads = aria2.get_downloads()
    result_list = []
    for i in downloads:
        m = staticmap.StaticMap(
            173, 147, 20, 20, url_template='https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}')
        coordinates = [
            [get_extent_by_timestamp(i.name[17:21]+'-'+i.name[21:23]+'-'+i.name[23:25])[
                0], get_extent_by_timestamp(i.name[17:21]+'-'+i.name[21:23]+'-'+i.name[23:25])[1]],
            [get_extent_by_timestamp(i.name[17:21]+'-'+i.name[21:23]+'-'+i.name[23:25])[
                2], get_extent_by_timestamp(i.name[17:21]+'-'+i.name[21:23]+'-'+i.name[23:25])[3]],
            [get_extent_by_timestamp(i.name[17:21]+'-'+i.name[21:23]+'-'+i.name[23:25])[
                4], get_extent_by_timestamp(i.name[17:21]+'-'+i.name[21:23]+'-'+i.name[23:25])[5]],
            [get_extent_by_timestamp(i.name[17:21]+'-'+i.name[21:23]+'-'+i.name[23:25])[
                6], get_extent_by_timestamp(i.name[17:21]+'-'+i.name[21:23]+'-'+i.name[23:25])[7]],
            [get_extent_by_timestamp(i.name[17:21]+'-'+i.name[21:23]+'-'+i.name[23:25])[
                0], get_extent_by_timestamp(i.name[17:21]+'-'+i.name[21:23]+'-'+i.name[23:25])[1]]
        ]
        line = staticmap.Line(coordinates, '#D2322D', 4)
        m.add_line(line)
        image = m.render()
        buffered = BytesIO()
        image.save(buffered, format="JPEG")
        img_str = base64.b64encode(buffered.getvalue()).decode('ascii')
        result_list.append(
            {'timeStamp': i.name[17:21]+'-'+i.name[21:23]+'-'+i.name[23:25],
             "downloadSize": "%.2f/%.2fG" % (i.progress/100*i.total_length/1024/1024/1024, i.total_length/1024/1024/1024),
             'percentageDownloaded': i.progress/100,
             'isDownloaded': i.is_complete,
             'imageBase64': img_str
             }
        )
    return HttpResponse(json.dumps(list(reversed(result_list))))


def get_workspace(request):
    result_list = []
    for i in task_queue:
        current_id = 0
        m = staticmap.StaticMap(
            173, 147, 20, 20, url_template='https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}')
        coordinates = [
            [get_extent_by_timestamp(i['description'][:10])[
                0], get_extent_by_timestamp(i['description'][:10])[1]],
            [get_extent_by_timestamp(i['description'][:10])[
                2], get_extent_by_timestamp(i['description'][:10])[3]],
            [get_extent_by_timestamp(i['description'][:10])[
                4], get_extent_by_timestamp(i['description'][:10])[5]],
            [get_extent_by_timestamp(i['description'][:10])[
                6], get_extent_by_timestamp(i['description'][:10])[7]],
            [get_extent_by_timestamp(i['description'][:10])[
                0], get_extent_by_timestamp(i['description'][:10])[1]]
        ]
        line = staticmap.Line(coordinates, '#D2322D', 4)
        m.add_line(line)
        image = m.render()
        buffered = BytesIO()
        image.save(buffered, format="JPEG")
        img_str = base64.b64encode(buffered.getvalue()).decode('ascii')
        result_list.append({
            'name': i['description'],
            'type': {'coregistration': 'Coregistration', 'interferogram': 'Interferogram', 'deburst': 'Debursted interferogram', 'tpr': 'Topo phase removed interferogram', 'multilooking': 'Multilooked interferogram', 'gpf': 'Goldstein filtered interferogram', 'pu': 'Phase unwrapped interferogram', 'p2d': 'Displacement', 'rdc': 'Geocoded displacement'}[i['type']],
            'id': current_id,
            'tiffUrl': self_host+'tiff_download/'+i['tiff_name'],
            'isDone': i['is_completed'],
            'size': i['size'],
            'extentImageBase64': img_str
        })
        current_id += 1
    return HttpResponse(json.dumps(list(reversed(result_list))))


def select_and_download_api(request, bounding_point_1, bounding_point_2, bounding_point_3, bounding_point_4):
    global select_and_download_state
    bounding_point_1 = [
        float(i) for i in bounding_point_1.split(':') if i.strip() != '']
    bounding_point_2 = [
        float(i) for i in bounding_point_2.split(':') if i.strip() != '']
    bounding_point_3 = [
        float(i) for i in bounding_point_3.split(':') if i.strip() != '']
    bounding_point_4 = [
        float(i) for i in bounding_point_4.split(':') if i.strip() != '']
    count_request_string = "https://api.daac.asf.alaska.edu/services/search/param?intersectsWith=POLYGON((%s %s,%s %s,%s %s,%s %s,%s %s))"\
        "&platform=SENTINEL-1&instrument=C-SAR&processinglevel=SLC&beamSwath=IW&maxResults=250&output=COUNT" %\
        (bounding_point_1[0], bounding_point_1[1], bounding_point_2[0], bounding_point_2[1], bounding_point_3[0],
         bounding_point_3[1], bounding_point_4[0], bounding_point_4[1], bounding_point_1[0], bounding_point_1[1])
    count = int(requests.get(count_request_string, proxies=proxies).text)
    entry_request_string = "https://api.daac.asf.alaska.edu/services/search/param?intersectsWith=POLYGON((%s %s,%s %s,%s %s,%s %s,%s %s))"\
        "&platform=SENTINEL-1&instrument=C-SAR&processinglevel=SLC&beamSwath=IW&maxResults=%s&output=jsonlite2" %\
        (bounding_point_1[0], bounding_point_1[1], bounding_point_2[0], bounding_point_2[1], bounding_point_3[0],
            bounding_point_3[1], bounding_point_4[0], bounding_point_4[1], bounding_point_1[0], bounding_point_1[1], count)
    r = requests.get(entry_request_string, proxies=proxies)
    select_and_download_state = json.loads(r.text)['results']
    http_resp_dict = []
    current_id = 1
    for i in select_and_download_state:
        geopolygon = i['w']
        nums = re.findall(r'\d+(?:\.\d*)?', geopolygon.rpartition(',')[0])
        coords = list(zip(*[iter(nums)] * 2))
        http_resp_dict.append({
            'id': current_id,
            'timeString': i['st'][:10],
            'size': '%.2fG' % (i['s']/1024),
            'x1': float(coords[0][0]),
            'y1': float(coords[0][1]),
            'x2': float(coords[1][0]),
            'y2': float(coords[1][1]),
            'x3': float(coords[2][0]),
            'y3': float(coords[2][1]),
            'x4': float(coords[3][0]),
            'y4': float(coords[3][1]),
        })
        current_id += 1
    data = []
    with open('./image_extent_cache/data.json', 'r') as f:
        data = json.load(f)
        for i in http_resp_dict:
            data[i['timeString']] = [i['x1'], i['y1'], i['x2'],
                                     i['y2'], i['x3'], i['y3'], i['x4'], i['y4']]
    with open('./image_extent_cache/data.json', 'w') as f:
        f.write(json.dumps(data))
    return HttpResponse(json.dumps(http_resp_dict))


def download_raw_by_id(request, id_list):
    global select_and_download_state
    id_list = [int(i) for i in id_list.split(':') if i.strip() != '']
    for i in id_list:
        download_add_queue(
            select_and_download_state[i-1]['du'].replace('{gn}', select_and_download_state[i-1]['gn']))
    return HttpResponse(json.dumps({
        "result": "success"
    }
    ))


def coreg_image_fetch(request):
    global coreg_state
    image_time_list = []
    coreg_state = {}
    for i in os.listdir('./download_images'):
        if(i.strip() != ''):
            image_time_list.append(i[17:21]+'-'+i[21:23]+'-'+i[23:25])
        coreg_state[i[17:21]+'-'+i[21:23]+'-'+i[23:25]] = i
    response_dict_list = []
    with open('./image_extent_cache/data.json', 'r') as f:
        data = json.load(f)
        current_id = 0
        for i in image_time_list:
            response_dict_list.append({
                'id': current_id,
                'timeStamp': i,
                'x1': data[i][0],
                'y1': data[i][1],
                'x2': data[i][2],
                'y2': data[i][3],
                'x3': data[i][4],
                'y3': data[i][5],
                'x4': data[i][6],
                'y4': data[i][7]
            })
            current_id += 1
    return HttpResponse(json.dumps(response_dict_list))


def coreg_start(request, master, slave, master_swath, slave_swath):
    global coreg_state
    global task_queue
    print('Coreg two things:')
    print('master', coreg_state[master], master_swath)
    print('slave', coreg_state[slave], slave_swath)
    tiff_name = str(uuid.uuid4())+'.tif'
    task_queue.append({'type': 'coregistration',
                       'description': master+' : '+slave,  # master_timestamp : slave_timestamp
                       'size': '',  # size of coregistration image should be an empty string
                       'is_completed': False,
                       'is_started': False,
                       # the function object of the task
                       'task_object': threading.Thread(target=__coreg_task_run, args=(coreg_state[master], coreg_state[slave], master_swath, slave_swath, master, slave, tiff_name)),
                       'area': get_extent_by_timestamp(master),
                       'tiff_name': tiff_name})  # the final tiff name. Just give a random name is ok.
    return HttpResponse(json.dumps({
        "result": "success"
    }))


def __coreg_task_run(master_file_name, slave_file_name, master_swath, slave_swath, master_timestamp, slave_timestamp, tiff_name):
    global coreg_state
    coreg_xml = '''<graph id="Graph">
  <version>1.0</version>
  <node id="Read">
    <operator>Read</operator>
    <sources/>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
    </parameters>
  </node>
  <node id="Read(2)">
    <operator>Read</operator>
    <sources/>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
    </parameters>
  </node>
  <node id="TOPSAR-Split">
    <operator>TOPSAR-Split</operator>
    <sources>
      <sourceProduct refid="Read"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <subswath>%s</subswath>
      <selectedPolarisations>VV</selectedPolarisations>
      <firstBurstIndex>1</firstBurstIndex>
      <lastBurstIndex>9</lastBurstIndex>
      <wktAoi/>
    </parameters>
  </node>
  <node id="TOPSAR-Split(2)">
    <operator>TOPSAR-Split</operator>
    <sources>
      <sourceProduct refid="Read(2)"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <subswath>%s</subswath>
      <selectedPolarisations>VV</selectedPolarisations>
      <firstBurstIndex>1</firstBurstIndex>
      <lastBurstIndex>9</lastBurstIndex>
      <wktAoi/>
    </parameters>
  </node>
  <node id="Apply-Orbit-File">
    <operator>Apply-Orbit-File</operator>
    <sources>
      <sourceProduct refid="TOPSAR-Split"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <orbitType>Sentinel Precise (Auto Download)</orbitType>
      <polyDegree>3</polyDegree>
      <continueOnFail/>
    </parameters>
  </node>
  <node id="Apply-Orbit-File(2)">
    <operator>Apply-Orbit-File</operator>
    <sources>
      <sourceProduct refid="TOPSAR-Split(2)"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <orbitType>Sentinel Precise (Auto Download)</orbitType>
      <polyDegree>3</polyDegree>
      <continueOnFail/>
    </parameters>
  </node>
  <node id="Back-Geocoding">
    <operator>Back-Geocoding</operator>
    <sources>
      <sourceProduct refid="Apply-Orbit-File"/>
      <sourceProduct.1 refid="Apply-Orbit-File(2)"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <demName>SRTM 3Sec</demName>
      <demResamplingMethod>BILINEAR_INTERPOLATION</demResamplingMethod>
      <externalDEMFile/>
      <externalDEMNoDataValue>0.0</externalDEMNoDataValue>
      <resamplingType>BILINEAR_INTERPOLATION</resamplingType>
      <maskOutAreaWithoutElevation>true</maskOutAreaWithoutElevation>
      <outputRangeAzimuthOffset>false</outputRangeAzimuthOffset>
      <outputDerampDemodPhase>false</outputDerampDemodPhase>
      <disableReramp>false</disableReramp>
    </parameters>
  </node>
  <node id="Write">
    <operator>Write</operator>
    <sources>
      <sourceProduct refid="Back-Geocoding"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
      <formatName>BEAM-DIMAP</formatName>
    </parameters>
  </node>
  <applicationData id="Presentation">
    <Description/>
    <node id="Read">
      <displayPosition x="25.0" y="13.0"/>
    </node>
    <node id="Read(2)">
      <displayPosition x="28.0" y="229.0"/>
    </node>
    <node id="TOPSAR-Split">
      <displayPosition x="16.0" y="50.0"/>
    </node>
    <node id="TOPSAR-Split(2)">
      <displayPosition x="11.0" y="194.0"/>
    </node>
    <node id="Apply-Orbit-File">
      <displayPosition x="12.0" y="84.0"/>
    </node>
    <node id="Apply-Orbit-File(2)">
      <displayPosition x="6.0" y="160.0"/>
    </node>
    <node id="Back-Geocoding">
      <displayPosition x="116.0" y="123.0"/>
    </node>
    <node id="Write">
      <displayPosition x="354.0" y="124.0"/>
    </node>
  </applicationData>
</graph>''' % (os.getcwd()+'\\download_images\\' + master_file_name, os.getcwd()+'\\download_images\\' + slave_file_name, master_swath, slave_swath, os.getcwd()+'\\coreg_images\\'+master_timestamp + ','+slave_timestamp+'.dim')
    uuid_gen = str(uuid.uuid4())
    with open('./coreg_xml/%s.xml' % uuid_gen, 'w') as f:
        f.write(coreg_xml)
    args = [gpt_location, os.getcwd()+'/coreg_xml/%s.xml' %
            uuid_gen, '-q', cpu_core, '-c', ram_usage]
    print(args)
    process = subprocess.Popen(
        args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline, b''):
        print(line.rstrip())
    process.stdout.close()
    process.wait()
    if process.returncode != 0:
        print('[ERROR] SOMETHING UNEXPECTED HAPPENED.')
    coreg_xml = '''<graph id="Graph">
  <version>1.0</version>
  <node id="Read">
    <operator>Read</operator>
    <sources/>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
    </parameters>
  </node>
  <node id="Write">
    <operator>Write</operator>
    <sources>
      <sourceProduct refid="Read"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
      <formatName>GeoTIFF-BigTIFF</formatName>
    </parameters>
  </node>
  <applicationData id="Presentation">
    <Description/>
    <node id="Read">
            <displayPosition x="36.0" y="133.0"/>
    </node>
    <node id="Write">
            <displayPosition x="455.0" y="135.0"/>
    </node>
  </applicationData>
</graph>''' % (os.getcwd()+'\\coreg_images\\'+master_timestamp + ','+slave_timestamp+'.dim', os.getcwd()+'\\tiffs\\' + tiff_name)
    uuid_gen = str(uuid.uuid4())
    with open('./coreg_xml/%s.xml' % uuid_gen, 'w') as f:
        f.write(coreg_xml)
    args = [gpt_location, os.getcwd()+'/coreg_xml/%s.xml' %
            uuid_gen, '-q', cpu_core, '-c', ram_usage]
    print(args)
    process = subprocess.Popen(
        args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline, b''):
        print(line.rstrip())
    process.stdout.close()
    process.wait()
    if process.returncode != 0:
        print('[ERROR] SOMETHING UNEXPECTED HAPPENED.')


def interf_image_fetch(request):
    coreg_image_list = [i.replace(',', ':').split(
        '.')[0] for i in os.listdir('./coreg_images') if i.endswith('.dim')]
    return HttpResponse(json.dumps(coreg_image_list))


def interf_image_generate(request, master_slave_pair):
    global coreg_state
    global task_queue
    master_slave_pair_file = master_slave_pair.replace(':', ',')+'.dim'
    print('Interf one image:')
    print('master_slave_pair', master_slave_pair_file)
    tiff_name = str(uuid.uuid4())+'.tif'
    task_queue.append({'type': 'interferogram',
                       'description': master_slave_pair,  # master_timestamp : slave_timestamp
                       'size': '',  # size of coregistration image should be an empty string
                       'is_completed': False,
                       'is_started': False,
                       # the function object of the task
                       'task_object': threading.Thread(target=__interf_task_run, args=(master_slave_pair_file, tiff_name)),
                       'area': get_extent_by_timestamp(master_slave_pair[:10]),
                       'tiff_name': tiff_name})  # the final tiff name. Just give a random name is ok.
    return HttpResponse(json.dumps({
        "result": "success"
    }))


def __interf_task_run(master_slave_pair_file, tiff_name):
    global coreg_state
    coreg_xml = '''<graph id="Graph">
  <version>1.0</version>
  <node id="Read">
    <operator>Read</operator>
    <sources/>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
    </parameters>
  </node>
  <node id="Interferogram">
    <operator>Interferogram</operator>
    <sources>
      <sourceProduct refid="Read"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <subtractFlatEarthPhase>true</subtractFlatEarthPhase>
      <srpPolynomialDegree>5</srpPolynomialDegree>
      <srpNumberPoints>501</srpNumberPoints>
      <orbitDegree>3</orbitDegree>
      <includeCoherence>true</includeCoherence>
      <cohWinAz>3</cohWinAz>
      <cohWinRg>10</cohWinRg>
      <squarePixel>true</squarePixel>
      <subtractTopographicPhase>false</subtractTopographicPhase>
      <demName>SRTM 3Sec</demName>
      <externalDEMFile/>
      <externalDEMNoDataValue>0.0</externalDEMNoDataValue>
      <externalDEMApplyEGM>true</externalDEMApplyEGM>
      <tileExtensionPercent>100</tileExtensionPercent>
      <outputElevation>false</outputElevation>
      <outputLatLon>false</outputLatLon>
    </parameters>
  </node>
  <node id="Write">
    <operator>Write</operator>
    <sources>
      <sourceProduct refid="Interferogram"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
      <formatName>BEAM-DIMAP</formatName>
    </parameters>
  </node>
  <applicationData id="Presentation">
    <Description/>
    <node id="Read">
            <displayPosition x="37.0" y="134.0"/>
    </node>
    <node id="Interferogram">
      <displayPosition x="237.0" y="134.0"/>
    </node>
    <node id="Write">
            <displayPosition x="455.0" y="135.0"/>
    </node>
  </applicationData>
</graph>''' % (os.getcwd()+'\\coreg_images\\' + master_slave_pair_file, os.getcwd()+'\\interferogram_images\\' + master_slave_pair_file)
    uuid_gen = str(uuid.uuid4())
    with open('./coreg_xml/%s.xml' % uuid_gen, 'w') as f:
        f.write(coreg_xml)
    args = [gpt_location, os.getcwd()+'/coreg_xml/%s.xml' %
            uuid_gen, '-q', cpu_core, '-c', ram_usage]
    print(args)
    process = subprocess.Popen(
        args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline, b''):
        print(line.rstrip())
    process.stdout.close()
    process.wait()
    if process.returncode != 0:
        print('[ERROR] SOMETHING UNEXPECTED HAPPENED.')
    coreg_xml = '''<graph id="Graph">
  <version>1.0</version>
  <node id="Read">
    <operator>Read</operator>
    <sources/>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
    </parameters>
  </node>
  <node id="Write">
    <operator>Write</operator>
    <sources>
      <sourceProduct refid="Read"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
      <formatName>GeoTIFF-BigTIFF</formatName>
    </parameters>
  </node>
  <applicationData id="Presentation">
    <Description/>
    <node id="Read">
            <displayPosition x="36.0" y="133.0"/>
    </node>
    <node id="Write">
            <displayPosition x="455.0" y="135.0"/>
    </node>
  </applicationData>
</graph>''' % (os.getcwd()+'\\interferogram_images\\'+master_slave_pair_file, os.getcwd()+'\\tiffs\\' + tiff_name)
    uuid_gen = str(uuid.uuid4())
    with open('./coreg_xml/%s.xml' % uuid_gen, 'w') as f:
        f.write(coreg_xml)
    args = [gpt_location, os.getcwd()+'/coreg_xml/%s.xml' %
            uuid_gen, '-q', cpu_core, '-c', ram_usage]
    print(args)
    process = subprocess.Popen(
        args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline, b''):
        print(line.rstrip())
    process.stdout.close()
    process.wait()
    if process.returncode != 0:
        print('[ERROR] SOMETHING UNEXPECTED HAPPENED.')


def deburst_image_fetch(request):
    interf_image_list = [i.replace(',', ':').split(
        '.')[0] for i in os.listdir('./interferogram_images') if i.endswith('.dim')]
    return HttpResponse(json.dumps(interf_image_list))


def deburst_image_generate(request, master_slave_pair):
    global coreg_state
    global task_queue
    master_slave_pair_file = master_slave_pair.replace(':', ',')+'.dim'
    print('Deburst one image:')
    print('master_slave_pair', master_slave_pair_file)
    tiff_name = str(uuid.uuid4())+'.tif'
    task_queue.append({'type': 'deburst',
                       'description': master_slave_pair,  # master_timestamp : slave_timestamp
                       'size': '',  # size of coregistration image should be an empty string
                       'is_completed': False,
                       'is_started': False,
                       # the function object of the task
                       'task_object': threading.Thread(target=__deburst_task_run, args=(master_slave_pair_file, tiff_name)),
                       'area': get_extent_by_timestamp(master_slave_pair[:10]),
                       'tiff_name': tiff_name})  # the final tiff name. Just give a random name is ok.
    return HttpResponse(json.dumps({
        "result": "success"
    }))


def __deburst_task_run(master_slave_pair_file, tiff_name):
    global coreg_state
    coreg_xml = '''<graph id="Graph">
  <version>1.0</version>
  <node id="Read">
    <operator>Read</operator>
    <sources/>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
    </parameters>
  </node>
  <node id="TOPSAR-Deburst">
    <operator>TOPSAR-Deburst</operator>
    <sources>
      <sourceProduct refid="Read"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <selectedPolarisations/>
    </parameters>
  </node>
  <node id="Write">
    <operator>Write</operator>
    <sources>
      <sourceProduct refid="TOPSAR-Deburst"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
      <formatName>BEAM-DIMAP</formatName>
    </parameters>
  </node>
  <applicationData id="Presentation">
    <Description/>
    <node id="Read">
            <displayPosition x="37.0" y="134.0"/>
    </node>
    <node id="TOPSAR-Deburst">
      <displayPosition x="235.0" y="144.0"/>
    </node>
    <node id="Write">
            <displayPosition x="455.0" y="135.0"/>
    </node>
  </applicationData>
</graph>''' % (os.getcwd()+'\\interferogram_images\\' + master_slave_pair_file, os.getcwd()+'\\deburst_images\\' + master_slave_pair_file)
    uuid_gen = str(uuid.uuid4())
    with open('./coreg_xml/%s.xml' % uuid_gen, 'w') as f:
        f.write(coreg_xml)
    args = [gpt_location, os.getcwd()+'/coreg_xml/%s.xml' %
            uuid_gen, '-q', cpu_core, '-c', ram_usage]
    print(args)
    process = subprocess.Popen(
        args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline, b''):
        print(line.rstrip())
    process.stdout.close()
    process.wait()
    if process.returncode != 0:
        print('[ERROR] SOMETHING UNEXPECTED HAPPENED.')
    coreg_xml = '''<graph id="Graph">
  <version>1.0</version>
  <node id="Read">
    <operator>Read</operator>
    <sources/>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
    </parameters>
  </node>
  <node id="Write">
    <operator>Write</operator>
    <sources>
      <sourceProduct refid="Read"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
      <formatName>GeoTIFF-BigTIFF</formatName>
    </parameters>
  </node>
  <applicationData id="Presentation">
    <Description/>
    <node id="Read">
            <displayPosition x="36.0" y="133.0"/>
    </node>
    <node id="Write">
            <displayPosition x="455.0" y="135.0"/>
    </node>
  </applicationData>
</graph>''' % (os.getcwd()+'\\deburst_images\\'+master_slave_pair_file, os.getcwd()+'\\tiffs\\' + tiff_name)
    uuid_gen = str(uuid.uuid4())
    with open('./coreg_xml/%s.xml' % uuid_gen, 'w') as f:
        f.write(coreg_xml)
    args = [gpt_location, os.getcwd()+'/coreg_xml/%s.xml' %
            uuid_gen, '-q', cpu_core, '-c', ram_usage]
    print(args)
    process = subprocess.Popen(
        args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline, b''):
        print(line.rstrip())
    process.stdout.close()
    process.wait()
    if process.returncode != 0:
        print('[ERROR] SOMETHING UNEXPECTED HAPPENED.')


def tpr_image_fetch(request):
    deburst_image_list = [i.replace(',', ':').split(
        '.')[0] for i in os.listdir('./deburst_images') if i.endswith('.dim')]
    return HttpResponse(json.dumps(deburst_image_list))


def tpr_image_generate(request, master_slave_pair):
    global coreg_state
    global task_queue
    master_slave_pair_file = master_slave_pair.replace(':', ',')+'.dim'
    print('TPR one image:')
    print('master_slave_pair', master_slave_pair_file)
    tiff_name = str(uuid.uuid4())+'.tif'
    task_queue.append({'type': 'tpr',
                       'description': master_slave_pair,  # master_timestamp : slave_timestamp
                       'size': '',  # size of coregistration image should be an empty string
                       'is_completed': False,
                       'is_started': False,
                       # the function object of the task
                       'task_object': threading.Thread(target=__tpr_task_run, args=(master_slave_pair_file, tiff_name)),
                       'area': get_extent_by_timestamp(master_slave_pair[:10]),
                       'tiff_name': tiff_name})  # the final tiff name. Just give a random name is ok.
    return HttpResponse(json.dumps({
        "result": "success"
    }))


def __tpr_task_run(master_slave_pair_file, tiff_name):
    global coreg_state
    coreg_xml = '''<graph id="Graph">
  <version>1.0</version>
  <node id="Read">
    <operator>Read</operator>
    <sources/>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
    </parameters>
  </node>
  <node id="TopoPhaseRemoval">
    <operator>TopoPhaseRemoval</operator>
    <sources>
      <sourceProduct refid="Read"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <orbitDegree>3</orbitDegree>
      <demName>SRTM 3Sec</demName>
      <externalDEMFile/>
      <externalDEMNoDataValue>0.0</externalDEMNoDataValue>
      <tileExtensionPercent>100</tileExtensionPercent>
      <outputTopoPhaseBand>false</outputTopoPhaseBand>
      <outputElevationBand>false</outputElevationBand>
      <outputLatLonBands>false</outputLatLonBands>
    </parameters>
  </node>
  <node id="Write">
    <operator>Write</operator>
    <sources>
      <sourceProduct refid="TopoPhaseRemoval"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
      <formatName>BEAM-DIMAP</formatName>
    </parameters>
  </node>
  <applicationData id="Presentation">
    <Description/>
    <node id="Read">
            <displayPosition x="37.0" y="134.0"/>
    </node>
    <node id="TopoPhaseRemoval">
      <displayPosition x="219.0" y="138.0"/>
    </node>
    <node id="Write">
            <displayPosition x="455.0" y="135.0"/>
    </node>
  </applicationData>
</graph>''' % (os.getcwd()+'\\deburst_images\\' + master_slave_pair_file, os.getcwd()+'\\tpr_images\\' + master_slave_pair_file)
    uuid_gen = str(uuid.uuid4())
    with open('./coreg_xml/%s.xml' % uuid_gen, 'w') as f:
        f.write(coreg_xml)
    args = [gpt_location, os.getcwd()+'/coreg_xml/%s.xml' %
            uuid_gen, '-q', cpu_core, '-c', ram_usage]
    print(args)
    process = subprocess.Popen(
        args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline, b''):
        print(line.rstrip())
    process.stdout.close()
    process.wait()
    if process.returncode != 0:
        print('[ERROR] SOMETHING UNEXPECTED HAPPENED.')
    coreg_xml = '''<graph id="Graph">
  <version>1.0</version>
  <node id="Read">
    <operator>Read</operator>
    <sources/>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
    </parameters>
  </node>
  <node id="Write">
    <operator>Write</operator>
    <sources>
      <sourceProduct refid="Read"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
      <formatName>GeoTIFF-BigTIFF</formatName>
    </parameters>
  </node>
  <applicationData id="Presentation">
    <Description/>
    <node id="Read">
            <displayPosition x="36.0" y="133.0"/>
    </node>
    <node id="Write">
            <displayPosition x="455.0" y="135.0"/>
    </node>
  </applicationData>
</graph>''' % (os.getcwd()+'\\tpr_images\\'+master_slave_pair_file, os.getcwd()+'\\tiffs\\' + tiff_name)
    uuid_gen = str(uuid.uuid4())
    with open('./coreg_xml/%s.xml' % uuid_gen, 'w') as f:
        f.write(coreg_xml)
    args = [gpt_location, os.getcwd()+'/coreg_xml/%s.xml' %
            uuid_gen, '-q', cpu_core, '-c', ram_usage]
    print(args)
    process = subprocess.Popen(
        args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline, b''):
        print(line.rstrip())
    process.stdout.close()
    process.wait()
    if process.returncode != 0:
        print('[ERROR] SOMETHING UNEXPECTED HAPPENED.')


def multilooking_image_fetch(request):
    tpr_image_list = [i.replace(',', ':').split(
        '.')[0] for i in os.listdir('./tpr_images') if i.endswith('.dim')]
    return HttpResponse(json.dumps(tpr_image_list))


def multilooking_image_generate(request, master_slave_pair, multilooking_times):
    global coreg_state
    global task_queue
    master_slave_pair_file = master_slave_pair.replace(':', ',')+'.dim'
    print('Multilooking one image:')
    print('master_slave_pair', master_slave_pair_file)
    tiff_name = str(uuid.uuid4())+'.tif'
    task_queue.append({'type': 'multilooking',
                       'description': master_slave_pair,  # master_timestamp : slave_timestamp
                       'size': '',  # size of coregistration image should be an empty string
                       'is_completed': False,
                       'is_started': False,
                       # the function object of the task
                       'task_object': threading.Thread(target=__multilooking_task_run, args=(master_slave_pair_file, multilooking_times, tiff_name)),
                       'area': get_extent_by_timestamp(master_slave_pair[:10]),
                       'tiff_name': tiff_name})  # the final tiff name. Just give a random name is ok.
    return HttpResponse(json.dumps({
        "result": "success"
    }))


def __multilooking_task_run(master_slave_pair_file, multilooking_times, tiff_name):
    global coreg_state
    coreg_xml = '''<graph id="Graph">
  <version>1.0</version>
  <node id="Read">
    <operator>Read</operator>
    <sources/>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
    </parameters>
  </node>
  <node id="Multilook">
    <operator>Multilook</operator>
    <sources>
      <sourceProduct refid="Read"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <sourceBands/>
      <nRgLooks>%s</nRgLooks>
      <nAzLooks>1</nAzLooks>
      <outputIntensity>false</outputIntensity>
      <grSquarePixel>true</grSquarePixel>
    </parameters>
  </node>
  <node id="Write">
    <operator>Write</operator>
    <sources>
      <sourceProduct refid="Multilook"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
      <formatName>BEAM-DIMAP</formatName>
    </parameters>
  </node>
  <applicationData id="Presentation">
    <Description/>
    <node id="Read">
            <displayPosition x="37.0" y="134.0"/>
    </node>
    <node id="Multilook">
      <displayPosition x="260.0" y="137.0"/>
    </node>
    <node id="Write">
            <displayPosition x="455.0" y="135.0"/>
    </node>
  </applicationData>
</graph>''' % (os.getcwd()+'\\tpr_images\\' + master_slave_pair_file, multilooking_times, os.getcwd()+'\\multilooking_images\\' + master_slave_pair_file)
    uuid_gen = str(uuid.uuid4())
    with open('./coreg_xml/%s.xml' % uuid_gen, 'w') as f:
        f.write(coreg_xml)
    args = [gpt_location, os.getcwd()+'/coreg_xml/%s.xml' %
            uuid_gen, '-q', cpu_core, '-c', ram_usage]
    print(args)
    process = subprocess.Popen(
        args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline, b''):
        print(line.rstrip())
    process.stdout.close()
    process.wait()
    if process.returncode != 0:
        print('[ERROR] SOMETHING UNEXPECTED HAPPENED.')
    coreg_xml = '''<graph id="Graph">
  <version>1.0</version>
  <node id="Read">
    <operator>Read</operator>
    <sources/>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
    </parameters>
  </node>
  <node id="Write">
    <operator>Write</operator>
    <sources>
      <sourceProduct refid="Read"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
      <formatName>GeoTIFF-BigTIFF</formatName>
    </parameters>
  </node>
  <applicationData id="Presentation">
    <Description/>
    <node id="Read">
            <displayPosition x="36.0" y="133.0"/>
    </node>
    <node id="Write">
            <displayPosition x="455.0" y="135.0"/>
    </node>
  </applicationData>
</graph>''' % (os.getcwd()+'\\multilooking_images\\'+master_slave_pair_file, os.getcwd()+'\\tiffs\\' + tiff_name)
    uuid_gen = str(uuid.uuid4())
    with open('./coreg_xml/%s.xml' % uuid_gen, 'w') as f:
        f.write(coreg_xml)
    args = [gpt_location, os.getcwd()+'/coreg_xml/%s.xml' %
            uuid_gen, '-q', cpu_core, '-c', ram_usage]
    print(args)
    process = subprocess.Popen(
        args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline, b''):
        print(line.rstrip())
    process.stdout.close()
    process.wait()
    if process.returncode != 0:
        print('[ERROR] SOMETHING UNEXPECTED HAPPENED.')


def gpf_image_fetch(request):
    multilooking_image_list = [i.replace(',', ':').split(
        '.')[0] for i in os.listdir('./multilooking_images') if i.endswith('.dim')]
    return HttpResponse(json.dumps(multilooking_image_list))


def gpf_image_generate(request, master_slave_pair):
    global coreg_state
    global task_queue
    master_slave_pair_file = master_slave_pair.replace(':', ',')+'.dim'
    print('Goldstein phase filtering one image:')
    print('master_slave_pair', master_slave_pair_file)
    tiff_name = str(uuid.uuid4())+'.tif'
    task_queue.append({'type': 'gpf',
                       'description': master_slave_pair,  # master_timestamp : slave_timestamp
                       'size': '',  # size of coregistration image should be an empty string
                       'is_completed': False,
                       'is_started': False,
                       # the function object of the task
                       'task_object': threading.Thread(target=__gpf_task_run, args=(master_slave_pair_file, tiff_name)),
                       'area': get_extent_by_timestamp(master_slave_pair[:10]),
                       'tiff_name': tiff_name})  # the final tiff name. Just give a random name is ok.
    return HttpResponse(json.dumps({
        "result": "success"
    }))


def __gpf_task_run(master_slave_pair_file, tiff_name):
    global coreg_state
    coreg_xml = '''<graph id="Graph">
  <version>1.0</version>
  <node id="Read">
    <operator>Read</operator>
    <sources/>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
    </parameters>
  </node>
  <node id="GoldsteinPhaseFiltering">
    <operator>GoldsteinPhaseFiltering</operator>
    <sources>
      <sourceProduct refid="Read"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <alpha>1.0</alpha>
      <FFTSizeString>64</FFTSizeString>
      <windowSizeString>3</windowSizeString>
      <useCoherenceMask>false</useCoherenceMask>
      <coherenceThreshold>0.2</coherenceThreshold>
    </parameters>
  </node>
  <node id="Write">
    <operator>Write</operator>
    <sources>
      <sourceProduct refid="GoldsteinPhaseFiltering"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
      <formatName>BEAM-DIMAP</formatName>
    </parameters>
  </node>
  <applicationData id="Presentation">
    <Description/>
    <node id="Read">
            <displayPosition x="37.0" y="134.0"/>
    </node>
    <node id="GoldsteinPhaseFiltering">
      <displayPosition x="214.0" y="137.0"/>
    </node>
    <node id="Write">
            <displayPosition x="455.0" y="135.0"/>
    </node>
  </applicationData>
</graph>''' % (os.getcwd()+'\\multilooking_images\\' + master_slave_pair_file, os.getcwd()+'\\gpf_images\\' + master_slave_pair_file)
    uuid_gen = str(uuid.uuid4())
    with open('./coreg_xml/%s.xml' % uuid_gen, 'w') as f:
        f.write(coreg_xml)
    args = [gpt_location, os.getcwd()+'/coreg_xml/%s.xml' %
            uuid_gen, '-q', cpu_core, '-c', ram_usage]
    print(args)
    process = subprocess.Popen(
        args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline, b''):
        print(line.rstrip())
    process.stdout.close()
    process.wait()
    if process.returncode != 0:
        print('[ERROR] SOMETHING UNEXPECTED HAPPENED.')
    coreg_xml = '''<graph id="Graph">
  <version>1.0</version>
  <node id="Read">
    <operator>Read</operator>
    <sources/>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
    </parameters>
  </node>
  <node id="Write">
    <operator>Write</operator>
    <sources>
      <sourceProduct refid="Read"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
      <formatName>GeoTIFF-BigTIFF</formatName>
    </parameters>
  </node>
  <applicationData id="Presentation">
    <Description/>
    <node id="Read">
            <displayPosition x="36.0" y="133.0"/>
    </node>
    <node id="Write">
            <displayPosition x="455.0" y="135.0"/>
    </node>
  </applicationData>
</graph>''' % (os.getcwd()+'\\gpf_images\\'+master_slave_pair_file, os.getcwd()+'\\tiffs\\' + tiff_name)
    uuid_gen = str(uuid.uuid4())
    with open('./coreg_xml/%s.xml' % uuid_gen, 'w') as f:
        f.write(coreg_xml)
    args = [gpt_location, os.getcwd()+'/coreg_xml/%s.xml' %
            uuid_gen, '-q', cpu_core, '-c', ram_usage]
    print(args)


def phase_unwrapping_image_fetch(request):
    gpf_image_list = [i.replace(',', ':').split(
        '.')[0] for i in os.listdir('./gpf_images') if i.endswith('.dim')]
    return HttpResponse(json.dumps(gpf_image_list))


def phase_unwrapping_image_generate(request, master_slave_pair):
    global coreg_state
    global task_queue
    master_slave_pair_file = master_slave_pair.replace(':', ',')+'.dim'
    print('Phase unwrapping one image:')
    print('master_slave_pair', master_slave_pair_file)
    tiff_name = str(uuid.uuid4())+'.tif'
    task_queue.append({'type': 'pu',
                       'description': master_slave_pair,  # master_timestamp : slave_timestamp
                       'size': '',  # size of coregistration image should be an empty string
                       'is_completed': False,
                       'is_started': False,
                       # the function object of the task
                       'task_object': threading.Thread(target=__phase_unwrapping_task_run, args=(master_slave_pair_file, tiff_name)),
                       'area': get_extent_by_timestamp(master_slave_pair[:10]),
                       'tiff_name': tiff_name})  # the final tiff name. Just give a random name is ok.
    return HttpResponse(json.dumps({
        "result": "success"
    }))


def __phase_unwrapping_task_run(master_slave_pair_file, tiff_name):
    try:
        os.mkdir('./snaphu_temp/%s' % master_slave_pair_file)
    except:
        pass
    global coreg_state
    args = ['"%s"' % gpt_location, 'SnaphuExport', '-Ssource=\"%s\" -PtargetFolder=\"%s\"' %
            (os.getcwd()+'\\gpf_images\\'+master_slave_pair_file, os.getcwd()+'\\snaphu_temp\\'+master_slave_pair_file), '-q', cpu_core, '-c', ram_usage]
    print(args)
    process = subprocess.Popen(
        ' '.join(args), stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline, b''):
        print(line.rstrip())
    process.stdout.close()
    process.wait()
    if process.returncode != 0:
        print('[ERROR] SOMETHING UNEXPECTED HAPPENED.')
    with open('./snaphu_temp/%s/%s/snaphu.conf' % (master_slave_pair_file, master_slave_pair_file.split('.dim')[0]), 'r') as f:
        command_line = [i.split()[1:] for i in f.readlines(
        ) if 'snaphu.conf' in i.split() and 'snaphu' in i.split()][0]
        command_line[0] = snaphu_location
        args = command_line
        print(args)
        process = subprocess.Popen(' '.join(args), stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                   cwd='./snaphu_temp/%s/%s' % (master_slave_pair_file, master_slave_pair_file.split('.dim')[0]))
        for line in iter(process.stdout.readline, b''):
            print(line.rstrip())
        process.stdout.close()
        process.wait()
        if process.returncode != 0:
            print('[ERROR] SOMETHING UNEXPECTED HAPPENED.')
    args = [gpt_location, 'SnaphuImport', '-t', os.getcwd()+'\\phase_unwrap_images\\'+master_slave_pair_file, '-q', cpu_core, '-c', ram_usage, os.getcwd()+'\\gpf_images\\'+master_slave_pair_file,
            os.getcwd()+'\\snaphu_temp\\'+master_slave_pair_file+'\\'+master_slave_pair_file.split('.dim')[0]+'\\'+[i for i in os.listdir(os.getcwd()+'\\snaphu_temp\\'+master_slave_pair_file+'\\'+master_slave_pair_file.split('.dim')[0]) if i.startswith('Unw') and i.endswith('.hdr')][0]]
    print(args)
    process = subprocess.Popen(
        args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline, b''):
        print(line.rstrip())
    process.stdout.close()
    process.wait()
    if process.returncode != 0:
        print('[ERROR] SOMETHING UNEXPECTED HAPPENED.')
    coreg_xml = '''<graph id="Graph">
  <version>1.0</version>
  <node id="Read">
    <operator>Read</operator>
    <sources/>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
    </parameters>
  </node>
  <node id="Write">
    <operator>Write</operator>
    <sources>
      <sourceProduct refid="Read"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
      <formatName>GeoTIFF-BigTIFF</formatName>
    </parameters>
  </node>
  <applicationData id="Presentation">
    <Description/>
    <node id="Read">
            <displayPosition x="36.0" y="133.0"/>
    </node>
    <node id="Write">
            <displayPosition x="455.0" y="135.0"/>
    </node>
  </applicationData>
</graph>''' % (os.getcwd()+'\\phase_unwrap_images\\'+master_slave_pair_file, os.getcwd()+'\\tiffs\\' + tiff_name)
    uuid_gen = str(uuid.uuid4())
    with open('./coreg_xml/%s.xml' % uuid_gen, 'w') as f:
        f.write(coreg_xml)
    args = [gpt_location, os.getcwd()+'/coreg_xml/%s.xml' %
            uuid_gen, '-q', cpu_core, '-c', ram_usage]
    print(args)
    process = subprocess.Popen(
        args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline, b''):
        print(line.rstrip())
    process.stdout.close()
    process.wait()
    if process.returncode != 0:
        print('[ERROR] SOMETHING UNEXPECTED HAPPENED.')


def p2d_image_fetch(request):
    phase_unwrap_image_list = [i.replace(',', ':').split(
        '.')[0] for i in os.listdir('./phase_unwrap_images') if i.endswith('.dim')]
    return HttpResponse(json.dumps(phase_unwrap_image_list))


def p2d_image_generate(request, master_slave_pair):
    global coreg_state
    global task_queue
    master_slave_pair_file = master_slave_pair.replace(':', ',')+'.dim'
    print('Phase to displacement one image:')
    print('master_slave_pair', master_slave_pair_file)
    tiff_name = str(uuid.uuid4())+'.tif'
    task_queue.append({'type': 'p2d',
                       'description': master_slave_pair,  # master_timestamp : slave_timestamp
                       'size': '',  # size of coregistration image should be an empty string
                       'is_completed': False,
                       'is_started': False,
                       # the function object of the task
                       'task_object': threading.Thread(target=__p2d_task_run, args=(master_slave_pair_file, tiff_name)),
                       'area': get_extent_by_timestamp(master_slave_pair[:10]),
                       'tiff_name': tiff_name})  # the final tiff name. Just give a random name is ok.
    return HttpResponse(json.dumps({
        "result": "success"
    }))


def __p2d_task_run(master_slave_pair_file, tiff_name):
    global coreg_state
    coreg_xml = '''<graph id="Graph">
  <version>1.0</version>
  <node id="Read">
    <operator>Read</operator>
    <sources/>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
    </parameters>
  </node>
  <node id="PhaseToDisplacement">
    <operator>PhaseToDisplacement</operator>
    <sources>
      <sourceProduct refid="Read"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement"/>
  </node>
  <node id="Write">
    <operator>Write</operator>
    <sources>
      <sourceProduct refid="PhaseToDisplacement"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
      <formatName>BEAM-DIMAP</formatName>
    </parameters>
  </node>
  <applicationData id="Presentation">
    <Description/>
    <node id="Read">
            <displayPosition x="37.0" y="134.0"/>
    </node>
    <node id="PhaseToDisplacement">
      <displayPosition x="224.0" y="135.0"/>
    </node>
    <node id="Write">
            <displayPosition x="455.0" y="135.0"/>
    </node>
  </applicationData>
</graph>''' % (os.getcwd()+'\\phase_unwrap_images\\' + master_slave_pair_file, os.getcwd()+'\\p2d_images\\' + master_slave_pair_file)
    uuid_gen = str(uuid.uuid4())
    with open('./coreg_xml/%s.xml' % uuid_gen, 'w') as f:
        f.write(coreg_xml)
    args = [gpt_location, os.getcwd()+'/coreg_xml/%s.xml' %
            uuid_gen, '-q', cpu_core, '-c', ram_usage]
    print(args)
    process = subprocess.Popen(
        args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline, b''):
        print(line.rstrip())
    process.stdout.close()
    process.wait()
    if process.returncode != 0:
        print('[ERROR] SOMETHING UNEXPECTED HAPPENED.')
    coreg_xml = '''<graph id="Graph">
  <version>1.0</version>
  <node id="Read">
    <operator>Read</operator>
    <sources/>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
    </parameters>
  </node>
  <node id="Write">
    <operator>Write</operator>
    <sources>
      <sourceProduct refid="Read"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
      <formatName>GeoTIFF-BigTIFF</formatName>
    </parameters>
  </node>
  <applicationData id="Presentation">
    <Description/>
    <node id="Read">
            <displayPosition x="36.0" y="133.0"/>
    </node>
    <node id="Write">
            <displayPosition x="455.0" y="135.0"/>
    </node>
  </applicationData>
</graph>''' % (os.getcwd()+'\\p2d_images\\'+master_slave_pair_file, os.getcwd()+'\\tiffs\\' + tiff_name)
    uuid_gen = str(uuid.uuid4())
    with open('./coreg_xml/%s.xml' % uuid_gen, 'w') as f:
        f.write(coreg_xml)
    args = [gpt_location, os.getcwd()+'/coreg_xml/%s.xml' %
            uuid_gen, '-q', cpu_core, '-c', ram_usage]
    print(args)
    process = subprocess.Popen(
        args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline, b''):
        print(line.rstrip())
    process.stdout.close()
    process.wait()
    if process.returncode != 0:
        print('[ERROR] SOMETHING UNEXPECTED HAPPENED.')


def p2d_image_fetch(request):
    phase_unwrap_image_list = [i.replace(',', ':').split(
        '.')[0] for i in os.listdir('./phase_unwrap_images') if i.endswith('.dim')]
    return HttpResponse(json.dumps(phase_unwrap_image_list))


def p2d_image_generate(request, master_slave_pair):
    global coreg_state
    global task_queue
    master_slave_pair_file = master_slave_pair.replace(':', ',')+'.dim'
    print('Phase to displacement one image:')
    print('master_slave_pair', master_slave_pair_file)
    tiff_name = str(uuid.uuid4())+'.tif'
    task_queue.append({'type': 'p2d',
                       'description': master_slave_pair,  # master_timestamp : slave_timestamp
                       'size': '',  # size of coregistration image should be an empty string
                       'is_completed': False,
                       'is_started': False,
                       # the function object of the task
                       'task_object': threading.Thread(target=__p2d_task_run, args=(master_slave_pair_file, tiff_name)),
                       'area': get_extent_by_timestamp(master_slave_pair[:10]),
                       'tiff_name': tiff_name})  # the final tiff name. Just give a random name is ok.
    return HttpResponse(json.dumps({
        "result": "success"
    }))


def __p2d_task_run(master_slave_pair_file, tiff_name):
    global coreg_state
    coreg_xml = '''<graph id="Graph">
  <version>1.0</version>
  <node id="Read">
    <operator>Read</operator>
    <sources/>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
    </parameters>
  </node>
  <node id="PhaseToDisplacement">
    <operator>PhaseToDisplacement</operator>
    <sources>
      <sourceProduct refid="Read"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement"/>
  </node>
  <node id="Write">
    <operator>Write</operator>
    <sources>
      <sourceProduct refid="PhaseToDisplacement"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
      <formatName>BEAM-DIMAP</formatName>
    </parameters>
  </node>
  <applicationData id="Presentation">
    <Description/>
    <node id="Read">
            <displayPosition x="37.0" y="134.0"/>
    </node>
    <node id="PhaseToDisplacement">
      <displayPosition x="224.0" y="135.0"/>
    </node>
    <node id="Write">
            <displayPosition x="455.0" y="135.0"/>
    </node>
  </applicationData>
</graph>''' % (os.getcwd()+'\\phase_unwrap_images\\' + master_slave_pair_file, os.getcwd()+'\\p2d_images\\' + master_slave_pair_file)
    uuid_gen = str(uuid.uuid4())
    with open('./coreg_xml/%s.xml' % uuid_gen, 'w') as f:
        f.write(coreg_xml)
    args = [gpt_location, os.getcwd()+'/coreg_xml/%s.xml' %
            uuid_gen, '-q', cpu_core, '-c', ram_usage]
    print(args)
    process = subprocess.Popen(
        args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline, b''):
        print(line.rstrip())
    process.stdout.close()
    process.wait()
    if process.returncode != 0:
        print('[ERROR] SOMETHING UNEXPECTED HAPPENED.')
    coreg_xml = '''<graph id="Graph">
  <version>1.0</version>
  <node id="Read">
    <operator>Read</operator>
    <sources/>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
    </parameters>
  </node>
  <node id="Write">
    <operator>Write</operator>
    <sources>
      <sourceProduct refid="Read"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
      <formatName>GeoTIFF-BigTIFF</formatName>
    </parameters>
  </node>
  <applicationData id="Presentation">
    <Description/>
    <node id="Read">
            <displayPosition x="36.0" y="133.0"/>
    </node>
    <node id="Write">
            <displayPosition x="455.0" y="135.0"/>
    </node>
  </applicationData>
</graph>''' % (os.getcwd()+'\\p2d_images\\'+master_slave_pair_file, os.getcwd()+'\\tiffs\\' + tiff_name)
    uuid_gen = str(uuid.uuid4())
    with open('./coreg_xml/%s.xml' % uuid_gen, 'w') as f:
        f.write(coreg_xml)
    args = [gpt_location, os.getcwd()+'/coreg_xml/%s.xml' %
            uuid_gen, '-q', cpu_core, '-c', ram_usage]
    print(args)
    process = subprocess.Popen(
        args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline, b''):
        print(line.rstrip())
    process.stdout.close()
    process.wait()
    if process.returncode != 0:
        print('[ERROR] SOMETHING UNEXPECTED HAPPENED.')


def rdc_image_fetch(request):
    p2d_image_list = [i.replace(',', ':').split(
        '.')[0] for i in os.listdir('./p2d_images') if i.endswith('.dim')]
    return HttpResponse(json.dumps(p2d_image_list))


def rdc_image_generate(request, master_slave_pair):
    global coreg_state
    global task_queue
    master_slave_pair_file = master_slave_pair.replace(':', ',')+'.dim'
    print('Range doppler correction one image:')
    print('master_slave_pair', master_slave_pair_file)
    tiff_name = str(uuid.uuid4())+'.tif'
    task_queue.append({'type': 'rdc',
                       'description': master_slave_pair,  # master_timestamp : slave_timestamp
                       'size': '',  # size of coregistration image should be an empty string
                       'is_completed': False,
                       'is_started': False,
                       # the function object of the task
                       'task_object': threading.Thread(target=__rdc_task_run, args=(master_slave_pair_file, tiff_name)),
                       'area': get_extent_by_timestamp(master_slave_pair[:10]),
                       'tiff_name': tiff_name})  # the final tiff name. Just give a random name is ok.
    return HttpResponse(json.dumps({
        "result": "success"
    }))


def __rdc_task_run(master_slave_pair_file, tiff_name):
    global coreg_state
    coreg_xml = '''<graph id="Graph">
  <version>1.0</version>
  <node id="Read">
    <operator>Read</operator>
    <sources/>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
    </parameters>
  </node>
  <node id="Terrain-Correction">
    <operator>Terrain-Correction</operator>
    <sources>
      <sourceProduct refid="Read"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <sourceBands>displacement</sourceBands>
      <demName>SRTM 3Sec</demName>
      <externalDEMFile/>
      <externalDEMNoDataValue>0.0</externalDEMNoDataValue>
      <externalDEMApplyEGM>true</externalDEMApplyEGM>
      <demResamplingMethod>BILINEAR_INTERPOLATION</demResamplingMethod>
      <imgResamplingMethod>BILINEAR_INTERPOLATION</imgResamplingMethod>
      <pixelSpacingInMeter>13.97</pixelSpacingInMeter>
      <pixelSpacingInDegree>1.2549464519149715E-4</pixelSpacingInDegree>
      <mapProjection>GEOGCS[&quot;WGS84(DD)&quot;, &#xd;
  DATUM[&quot;WGS84&quot;, &#xd;
    SPHEROID[&quot;WGS84&quot;, 6378137.0, 298.257223563]], &#xd;
  PRIMEM[&quot;Greenwich&quot;, 0.0], &#xd;
  UNIT[&quot;degree&quot;, 0.017453292519943295], &#xd;
  AXIS[&quot;Geodetic longitude&quot;, EAST], &#xd;
  AXIS[&quot;Geodetic latitude&quot;, NORTH]]</mapProjection>
      <alignToStandardGrid>false</alignToStandardGrid>
      <standardGridOriginX>0.0</standardGridOriginX>
      <standardGridOriginY>0.0</standardGridOriginY>
      <nodataValueAtSea>true</nodataValueAtSea>
      <saveDEM>false</saveDEM>
      <saveLatLon>false</saveLatLon>
      <saveIncidenceAngleFromEllipsoid>false</saveIncidenceAngleFromEllipsoid>
      <saveLocalIncidenceAngle>false</saveLocalIncidenceAngle>
      <saveProjectedLocalIncidenceAngle>false</saveProjectedLocalIncidenceAngle>
      <saveSelectedSourceBand>true</saveSelectedSourceBand>
      <saveLayoverShadowMask>false</saveLayoverShadowMask>
      <applyRadiometricNormalization>false</applyRadiometricNormalization>
      <saveSigmaNought>false</saveSigmaNought>
      <saveGammaNought>false</saveGammaNought>
      <saveBetaNought>false</saveBetaNought>
      <incidenceAngleForSigma0>Use projected local incidence angle from DEM</incidenceAngleForSigma0>
      <incidenceAngleForGamma0>Use projected local incidence angle from DEM</incidenceAngleForGamma0>
      <auxFile>Latest Auxiliary File</auxFile>
      <externalAuxFile/>
    </parameters>
  </node>
  <node id="Write">
    <operator>Write</operator>
    <sources>
      <sourceProduct refid="Terrain-Correction"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
      <formatName>BEAM-DIMAP</formatName>
    </parameters>
  </node>
  <applicationData id="Presentation">
    <Description/>
    <node id="Read">
            <displayPosition x="37.0" y="134.0"/>
    </node>
    <node id="Terrain-Correction">
      <displayPosition x="242.0" y="152.0"/>
    </node>
    <node id="Write">
            <displayPosition x="455.0" y="135.0"/>
    </node>
  </applicationData>
</graph>''' % (os.getcwd()+'\\p2d_images\\' + master_slave_pair_file, os.getcwd()+'\\rdc_images\\' + master_slave_pair_file)
    uuid_gen = str(uuid.uuid4())
    with open('./coreg_xml/%s.xml' % uuid_gen, 'w') as f:
        f.write(coreg_xml)
    args = [gpt_location, os.getcwd()+'/coreg_xml/%s.xml' %
            uuid_gen, '-q', cpu_core, '-c', ram_usage]
    print(args)
    process = subprocess.Popen(
        args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline, b''):
        print(line.rstrip())
    process.stdout.close()
    process.wait()
    if process.returncode != 0:
        print('[ERROR] SOMETHING UNEXPECTED HAPPENED.')
    coreg_xml = '''<graph id="Graph">
  <version>1.0</version>
  <node id="Read">
    <operator>Read</operator>
    <sources/>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
    </parameters>
  </node>
  <node id="Write">
    <operator>Write</operator>
    <sources>
      <sourceProduct refid="Read"/>
    </sources>
    <parameters class="com.bc.ceres.binding.dom.XppDomElement">
      <file>%s</file>
      <formatName>GeoTIFF-BigTIFF</formatName>
    </parameters>
  </node>
  <applicationData id="Presentation">
    <Description/>
    <node id="Read">
            <displayPosition x="36.0" y="133.0"/>
    </node>
    <node id="Write">
            <displayPosition x="455.0" y="135.0"/>
    </node>
  </applicationData>
</graph>''' % (os.getcwd()+'\\rdc_images\\'+master_slave_pair_file, os.getcwd()+'\\tiffs\\' + tiff_name)
    uuid_gen = str(uuid.uuid4())
    with open('./coreg_xml/%s.xml' % uuid_gen, 'w') as f:
        f.write(coreg_xml)
    args = [gpt_location, os.getcwd()+'/coreg_xml/%s.xml' %
            uuid_gen, '-q', cpu_core, '-c', ram_usage]
    print(args)
    process = subprocess.Popen(
        args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline, b''):
        print(line.rstrip())
    process.stdout.close()
    process.wait()
    if process.returncode != 0:
        print('[ERROR] SOMETHING UNEXPECTED HAPPENED.')

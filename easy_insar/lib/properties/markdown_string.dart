class WelcomePageMarkdownString {
  static const String data = '''
# Introduction

Thanks for using Easy InSAR, a free and easy to use platform for DInSAR processing.

# What is InSAR?

Interferometric synthetic aperture radar, abbreviated InSAR (or deprecated IfSAR), is a radar technique used in geodesy and remote sensing. This geodetic method uses two or more synthetic aperture radar (SAR) images to generate maps of surface deformation or digital elevation, using differences in the phase of the waves returning to the satellite or aircraft. The technique can potentially measure millimeter-scale changes in deformation over spans of days to years. It has applications for geophysical monitoring of natural hazards, for example earthquakes, volcanoes and landslides, and in structural engineering, in particular monitoring of subsidence and structural stability.

# What is DInSAR?

The D in DInSAR stands for “Differential”, that means it is used to observe phase changes between two images in a given time. So, it is a series of technique that can help monitor time series of changes in the surface, especially the land deformation info. Currently, there are many DInSAR techniques available, among which the most advanced is PSInSAR(Persistent Scatterer InSAR) and SBAS(Small BAseline Subset), but the conventional double-paired interferogram is still used.

# What can this application do?

Firstly, downloading InSAR data, which is the first step to do if you want to produce any InSAR product. Don't worry, this application will do the downloading job for you, what you need to do is just input some parameters and wait for the application to finish fetching remote resources.

Despite of downloading data, this application can also help you to simply walk through the process of InSAR processing. You can choose the InSAR product you want to process, and the application will automatically generate the necessary files for you. Currently this application can serve you to process basic interferogram and do PSInSAR job(MATLAB license is required for the server-side to process PSInSAR data).

# So, how to use this application?

First, be sure to look at “Principles of InSAR” on the sidebar. It contains a lot information about what InSAR is. Not knowing the basic knowledge is harmful to your research. Then, please read the “Guidance of Easy InSAR Application”, which contains an real-world example, covering all the processes included in this app.
''';
}

class PrinciplesOfInSARMarkdownString {
  static const String data = '''
# InSAR technique details

InSAR (Interferometric Synthetic Aperture Radar) is a technique for mapping ground deformation using radar images of the Earth's surface that are collected from orbiting satellites. Unlike visible or infrared light, radar waves penetrate most weather clouds and are equally effective in darkness. So with InSAR it is possible to track ground deformation even in bad weather and at night – two big advantages during a volcanic crisis.

Two radar images of the same area that were collected at different times from similar vantage points in space can be compared against each other. Any movement of the ground surface toward or away from the satellite can be measured and portrayed as a "picture" – not of the surface itself but of how much the surface moved (deformed) during the time between images.

![](resource:assets/1652197345794.png)

To create this radar deformation"picture" a pulse of radar energy is emitted from a satellite, scattered by the Earth's surface, and recorded back at the satellite with two types of information: amplitude and phase. The amplitude is the strength of the return signal, influenced by the physical properties of the surface. The round trip distance from the satellite to the ground and back again is measured in units of the radar wavelength, and changes in that distance between the time two radar images were collected show up as a phase difference. Combining these two images is called "interfering" because combining two waves causes them to either reinforce or cancel one another.

![](resource:assets/1652197366109.png)

InSAR greatly extends the ability of scientists to monitor volcanoes because, unlike other techniques that rely on measurements at a few points, InSAR produces a map of ground deformation that covers a very large spatial area with centimeter-scale accuracy. This technique is especially useful at remote, difficult-to-access volcanoes and at locations where hazardous conditions prevent or limit ground-based volcano monitoring.

Currently the most widely used InSAR satellite is Sentinel-1, which is operated by ESA and is open to everyone. In this program, we will mostly use Sentinel-1 data for processing.

![](resource:assets/1652197485767.png)
''';
}

class GuidanceToEasyInSARMarkdownString {
  static const String data =
      '''Welcome! Please see the video distributed with your binary executable. A video tutorial is better than just reading text-based articles.''';
}

class AboutMarkdownString {
  static const String data = '''
  ![](resource:assets/aboutbanner.png)

  # Author
  
  Admittedly_Goat (杨城冉)

  # Disclaimer

  This application is not affiliated with NASA or any other organization.

  THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM “AS IS” WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.
  ''';
}

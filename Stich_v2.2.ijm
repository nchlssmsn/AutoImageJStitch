// https://imagej.nih.gov/ij/developer/macro/functions.html
// Script uses the STITCH algorithm, and must first be installed.
// https://github.com/USNISTGOV/MIST/wiki/Install-Guide


///////////////////////////////////  Usage ///////////////////////////////////
// Run script and point to last tile containing the last col and row number 
// or the last file e.g. DRIE_U00074_bot_afterstrip_002_X032_Y010_C or
// e.g. fc2_sae_2020-08-20-163824-0039
// Coeffient next to X (032) and Y (010) will be populated in MIST parameter
// Script will automatically process, and output a single jpg file with the 
// filename but without regex eg DRIE_U00074_bot_afterstrip_002-stitch-jpg
// File will open, display stiched image and close by itself.  
// Closing the file will prevent jpg from being generated.
// Safest is to wait for the beep for indication of completion

// The directory should not contain any spaces as this breaks the script.
// getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);

"\\Clear"
print("TechniStich");
print("----------------------");
print("Nic. Sam-Soon");
print("Rev 1. 03/30/2020");
print("Stitches get snitches");
print("Running ImageJ version: ",IJ.getFullVersion());
//print("Current Free Memory:",IJ.freeMemory());
print("\n");

// %%%%%%%%%%%%%%%%% User Input required %%%%%%%%%%%%%%%%%
// "Row/Column or Sequential files?Row/Column:1 Sequential:0"
isRowColumnFormat=0;

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


// File dialog: Open file 
Filepath = File.openDialog("Select file (eg DRIE_U0069-bot_001_X022_Y011_C.bmp)");
starttime = getTime();
file_dir = File.getParent(Filepath);
files = getFileList(file_dir);
filename_long = File.getName(Filepath);

if (isRowColumnFormat==1) {
// Get grid number (Width, Height) from specified file
filename_pattern = substring(filename_long, lengthOf(filename_long)-16, lengthOf(filename_long));
filename_simple = substring(filename_long, 0, lengthOf(filename_long)-16);
filename_pattern_regex = filename_simple + "_X{ccc}_Y{rrr}_C.bmp";
width = substring(filename_pattern, 3, 5);
height = substring(filename_pattern, 8, 10);
filenamepattern = "ROWCOL";
numpattern = "HORIZONTALCOMBING";
scale_distance=1176;
scale_known = 2.93;
} else {
// e.g. fc2_save_2020-08-20-163824-0039.jpg
filename_pattern = substring(filename_long, lengthOf(filename_long)-5, lengthOf(filename_long));
filename_simple = substring(filename_long, 0,lengthOf(filename_long)-8);
filename_pattern_regex= filename_simple + "{pppp}.jpg";
filenamepattern = "SEQUENTIAL";
numpattern = "HORIZONTALCONTINUOUS";
starttile_row = 0;
starttile_col = 0;
width = 11; //24;
height = 8; // 11;
scale_distance=75.5;
scale_known = 0.1;
}

// File information for user debugging
print("File path:", Filepath);
print("Directory:", file_dir);
print("Filename long:", filename_long);
print("Filename simple:", filename_simple);
print("File pattern regex:",filename_pattern_regex);
print("Number of files in directory: ", files.length);
if (files.length < parseInt(width)*parseInt(height)) {
	exit("Number of files in directory ("+files.length+") is less than expected ("+width*height+")");
}
print("\n");

// Other MIST parameters
h_overlap = 10.0;
v_overlap = 10.0;
save_tif_output = false; // Set to true to save original stiched tif. Warning: very large file
log_level = "Mandatory"; //Set to "None" to remove log
blending = "Average";  // Default: "Overlay"

// begin macro 
run("MIST", "gridwidth="+width+" gridheight="+height+" starttilerow=1 starttilecol=1 starttile=0 imagedir="+file_dir+" filenamepattern="+filename_pattern_regex+" filenamepatterntype="+filenamepattern+" gridorigin=UL assemblefrommetadata=false globalpositionsfile=[] numberingpattern="+numpattern+" startrow=0 startcol=0 extentwidth="+width+" extentheight="+height+" timeslices=0 istimeslicesenabled=false outputpath="+file_dir+" displaystitching=true outputfullimage="+save_tif_output+"  outputmeta=true outputimgpyramid=false blendingmode=overlay blendingalpha=NaN outfileprefix=img- programtype=AUTO numcputhreads=8 loadfftwplan=true savefftwplan=true fftwplantype=MEASURE fftwlibraryname=libfftw3 fftwlibraryfilename=libfftw3.dll planpath=C:\\Users\\me\\Documents\\fiji-win64\\Fiji.app\\lib\\fftw\\fftPlans fftwlibrarypath=C:\\Users\\me\\Documents\\fiji-win64\\Fiji.app\\lib\\fftw stagerepeatability=0 horizontaloverlap="+h_overlap+" verticaloverlap="+v_overlap+" numfftpeaks=0 overlapuncertainty=NaN isusedoubleprecision=false isusebioformats=false issuppressmodelwarningdialog=false isenablecudaexceptions=false translationrefinementmethod=SINGLE_HILL_CLIMB numtranslationrefinementstartpoints=16 headless=false loglevel="+log_level+" debuglevel=Mandatory");
//}

// Set scale bar
print("\n");
print("Setting scale bar...");
run("Set Scale...", "distance="+scale_distance+" known="+scale_known+" pixel=1 unit=mm global");
run("Scale Bar...", "width=10 height=150 font=448 color=White background=None location=[Lower Right] bold overlay");

// Add decorations: TPB text and timestamp in top right corner of image.
decorator = "TPB";  // Enter text to overlay on image eg. "Technicolor\n"
// Output of function File.dateLastModified(path) -> Tue Aug 25 10:59:30 PDT 2020
modifieddate = File.dateLastModified(Filepath);
timestamp = substring(modifieddate,8,10)+substring(modifieddate, 4,7)+substring(modifieddate, 24);
Overlay.drawString(decorator+"-"+timestamp, getWidth()/(10/8.5), getHeight()/25);
Overlay.setStrokeColor("white");


// Save as jpg, variable quality
// 32x10 tiled image will be around 25-27 Mb @ quality 85, and 150Mb @ quality 100
// Use quality=100 for surface contamination studies
// https://imagej.nih.gov/ij/macros/SaveAsJPEG.txt

print("JPG quality set to 75");
print("Saving as jpg...");
setOption("AutoContrast", true);
quality = 75;
run("Input/Output...", "jpeg="+quality);
saveAs("jpg",file_dir + "\\" + filename_simple + "-stitch");

endtime = getTime();
print("Script complete. Image saved in output directory.");
print("Time elapsed since start(s): ",(endtime-starttime)/1000);
beep();
close();
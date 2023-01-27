//@String inDir
//@String outDir
//Choose Channel used for Segmentation
Segment=1;

//Predefine the amount of Gaussian Blur
Blur=2;

//Predefine the sigma for the Laplace Filter (higher value for bigger structures)
Laplace=2;

//Predefine the Radius for Background subtraction
Rolling_Ball=40;

//Minimum and Maximum Value for output Image
min=0.01;
max=0.5;

setBatchMode(false);
roiManager("Reset");
run("Close All");

fileList = getFileList(inDir);
fileListOut = getFileList(outDir);
for (i=0; i<fileList.length; i++) {
    if (endsWith(fileList[i], ".czi") || endsWith(fileList[i], ".ome.tif")) {
        showProgress(i+1, fileList.length);
        file = inDir + fileList[i];
        inFileCut = lengthOf(file)-4;
        inFile=substring(file,0,inFileCut);
        outFileTemp = outDir + fileList[i];
        cut=lengthOf(outFileTemp)-4;
        if (endsWith(fileList[i], ".ome.tif")){
            cut=lengthOf(outFileTemp)-8;
        }
        outFile=substring(outFileTemp,0,cut);

        print("Outfile= "+outFile);
        run("Bio-Formats Importer", "open='" + file + "' color_mode=Custom view=Hyperstack stack_order=XYCZT series_0_channel_0_red=255 series_0_channel_0_green=255 series_0_channel_0_blue=255 series_0_channel_1_red=255 series_0_channel_1_green=255 series_0_channel_1_blue=255 series_0_channel_2_red=255 series_0_channel_2_green=255 series_0_channel_2_blue=255 series_0_channel_3_red=255 series_0_channel_3_green=255 series_0_channel_3_blue=255");
        saveAs("Tiff", outFile+"");
        TitleImage=getTitle();
        cut=lengthOf(TitleImage)-4;
        TitleImage2=substring(TitleImage,0,cut);
        run("32-bit");
        run("Gaussian Blur...", "sigma="+Blur+" stack");

    //Split into single Images
        selectWindow(TitleImage);
        setSlice(1);
        run("Duplicate...", "title=Ch1");
        selectWindow(TitleImage);
        run("Next Slice [>]");
        run("Next Slice [>]");
        run("Duplicate...", "title=Ch2");
        selectWindow(TitleImage);
        run("Close");

    //Filter for Segmentation
        selectWindow("Ch"+Segment);
        run("Duplicate...", " ");
        rename("Backsubtract");
        run("Subtract Background...", "rolling="+Rolling_Ball+"");
        run("FeatureJ Laplacian", "compute smoothing="+Laplace+"");
        setAutoThreshold("Triangle");
        setThreshold(-10000000000, -0.38);
        setOption("BlackBackground", true);
        run("Convert to Mask");
        run("32-bit");
        setAutoThreshold("Default dark");
        run("NaN Background");
        run("Divide...", "value=255");

    //Create Ratiometric Image
        imageCalculator("Divide create 32-bit", "Ch2","Ch1");
        imageCalculator("Multiply create 32-bit", "Result of Ch2","Backsubtract Laplacian");

    //Set Display and save
        run("Green Fire Blue");
        run("Select None");
        setMinAndMax(min, max);
        run("Calibration Bar...", "location=[Upper Right] fill=White label=Black number=5 decimal=3 font=12 zoom=1 overlay");
        saveAs("Tiff", outFile+"_ratio");
        //setMinAndMax(min, max);
        //run("Calibration Bar...", "location=[Upper Right] fill=White label=Black number=5 decimal=3 font=12 zoom=1");
        //saveAs("Tiff", outFile+"_calibration");

        run("Close All");
    }
}
run("Quit");
package com.visioncameradynamsoftlabelrecognizer;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CapturedResult;
import com.facebook.react.bridge.ReactApplicationContext;
import com.mrousavy.camera.core.FrameInvalidError;
import com.mrousavy.camera.frameprocessors.Frame;
import com.mrousavy.camera.frameprocessors.FrameProcessorPlugin;
import com.dynamsoft.dlr.*;
import com.mrousavy.camera.frameprocessors.VisionCameraProxy;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class VisionCameraDLRPlugin extends FrameProcessorPlugin {

    private ReactApplicationContext context;
    private CaptureVisionRouter router = VisionCameraDynamsoftLabelRecognizerModule.router;
    @Nullable
    @Override
    public Object callback(@NonNull Frame frame, @Nullable Map<String, Object> arguments) {
        // code goes here
        Log.d("DLR","call back");
        Map<String, Object> scanResult = new HashMap<>();
        List<Object> array = new ArrayList<>();

        String template = "ReadPassportAndId";
        if (arguments != null && arguments.containsKey("template")) {
          template = (String) arguments.get("template");
        }

        try {
            @SuppressLint("UnsafeOptInUsageError")
            Bitmap bm = BitmapUtils.getBitmap(frame);
            if (arguments != null && arguments.containsKey("scanRegion")) {
                Map<String,Object> scanRegion = (Map<String, Object>) arguments.get("scanRegion");
                double left = ((double) scanRegion.get("left")) / 100.0 * bm.getWidth();
                double top = ((double) scanRegion.get("top")) / 100.0 * bm.getHeight();
                double width = ((double) scanRegion.get("width")) / 100.0 * bm.getWidth();
                double height = ((double) scanRegion.get("height")) / 100.0 * bm.getHeight();
                bm = Bitmap.createBitmap(bm, (int) left, (int) top, (int) width, (int) height, null, false);
            }
            try {
                CapturedResult result = router.capture(bm,template);
                RecognizedTextLinesResult linesResult = result.getRecognizedTextLinesResult();
                if (linesResult != null) {
                    array.add(Utils.getMapFromLinesResult(linesResult).toHashMap());
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            if (arguments != null && arguments.containsKey("includeImageBase64")) {
                boolean includeImageBase64 = (boolean) arguments.get("includeImageBase64");
                if (includeImageBase64 == true) {
                    scanResult.put("imageBase64",Utils.bitmap2Base64(bm));
                }
            }
        } catch (FrameInvalidError e) {
            e.printStackTrace();
            Log.d("DLR",e.getMessage());
        }
        scanResult.put("results",array);
        return scanResult;
    }

    VisionCameraDLRPlugin(@NonNull VisionCameraProxy proxy, @Nullable Map<String, Object> options) {super();}

}

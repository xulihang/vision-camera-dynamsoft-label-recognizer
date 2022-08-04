//
//  LabelRecognizerManager.swift
//  VisionCameraDynamsoftLabelRecognizer
//
//  Created by xulihang on 2022/8/3.
//  Copyright © 2022 Facebook. All rights reserved.
//

import Foundation
import DynamsoftLabelRecognizer

class LabelRecognizerManager:NSObject, DLRLicenseVerificationDelegate {
    private var recognizer:DynamsoftLabelRecognizer!;
    private var currentModelFolder = "";
    private var currentTemplate = "";
    private var mLicense = "";
    
    init(license:String){
        super.init()
        mLicense = license
        initDLR(license: license)
    }
    
    public func getRecognizer() -> DynamsoftLabelRecognizer{
        if recognizer == nil {
            initDLR(license: mLicense)
        }
        return recognizer
    }
    
    public func destroy() {
        recognizer.dispose()
        recognizer = nil
    }
    
    private func initDLR(license:String) {
        DynamsoftLabelRecognizer.initLicense(license, verificationDelegate: self)
        recognizer = DynamsoftLabelRecognizer.init()
    }
    
    func dlrLicenseVerificationCallback(_ isSuccess: Bool, error: Error?) {
        var msg:String? = ""
        if(error != nil)
        {
            let err = error as NSError?
            if err?.code == -1009 {
                msg = "Dynamsoft Label Recognizer is unable to connect to the public Internet to acquire a license. Please connect your device to the Internet or contact support@dynamsoft.com to acquire an offline license."
            }else{
                msg = err!.userInfo[NSUnderlyingErrorKey] as? String
                if(msg == nil)
                {
                    msg = err?.localizedDescription
                }
            }
            print(msg ?? "")
        }
    }
    
    
    public func updateTemplate(template:String){
        if (currentTemplate != template) {
            var clearErr : NSError? = NSError()
            recognizer.clearAppendedSettings(error: &clearErr)
            var err : NSError? = NSError()
            recognizer.appendSettingsFromString(content: template, error: &err)
            print("template added")
            print(template)
            if err?.code != 0 {
                print("error")
                var errMsg:String? = ""
                errMsg = err!.userInfo[NSUnderlyingErrorKey] as? String
                print(errMsg ?? "")
            }
            currentTemplate = template;
        }
    }
    

    public func useCustomModel(modelFolder:String,modelFileNames: [String])   {
        if (modelFolder != currentModelFolder) {
            currentModelFolder = modelFolder
            DynamsoftLabelRecognizer.eraseAllCharacterModels()
            for model in modelFileNames {
                
                guard let prototxt = Bundle.main.url(
                    forResource: model,
                    withExtension: "prototxt",
                    subdirectory: modelFolder
                ) else {
                    print("model not exist")
                    return
                }

                let datapro = try! Data.init(contentsOf: prototxt)
                let txt = Bundle.main.url(forResource: model, withExtension: "txt", subdirectory: modelFolder)
                let datatxt = try! Data.init(contentsOf: txt!)
                let caffemodel = Bundle.main.url(forResource: model, withExtension: "caffemodel", subdirectory: modelFolder)
                let datacaf = try! Data.init(contentsOf: caffemodel!)
                DynamsoftLabelRecognizer.appendCharacterModel(name: model, prototxtBuffer: datapro, txtBuffer: datatxt, characterModelBuffer: datacaf)
                print("load model %@", model)
            }
        }
    }
}

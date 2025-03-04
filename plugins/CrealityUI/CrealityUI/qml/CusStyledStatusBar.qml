import QtQuick 2.12
import QtQuick.Controls 2.12
import ".."
import "../qml"

Item{
    id: statusBur
    visible: true
    property var object
    property var showProcess:true

    signal acceptButton()
    signal cancelJobButton()
    signal sigJobStart()
    signal sigJobEnd()

    Connections {
        target: kernel_slice_flow
        onSupportStructureRequired: {
            console.log("-------------------")
            standaloneWindow.tipsItem.funcs[0] = addSupport
            if(kernel_kernel.currentPhase === 1)
                standaloneWindow.tipsItem.visible = true
        }
    }


    Connections{
        target: kernel_kernel
        onCurrentPhaseChanged:{
            if(kernel_kernel.currentPhase === 0)
                standaloneWindow.tipsItem.visible = false
            console.log("_+_++_+_++__++_+_+_+_+_+_+_+_+_+_")
        }
    }

    function addSupport(){
        cancelButton.sigButtonClicked()
        kernel_kernel.setKernelPhase(0)
        standaloneWindow.tipsItem.visible = false
    }

    UploadMessageDlg {
        id: need_support_structure_dialog

        visible: false
        messageType: 0
        msgText: qsTr("The model has not been supported and may fail to print. Do you want to continue adding supports before slicing?")

        onSigOkButtonClicked: {
            cancelButton.sigButtonClicked()
            need_support_structure_dialog.visible = false
        }

        onSigCancelButtonClicked:{
            need_support_structure_dialog.visible = false
        }
    }

    Rectangle
    {
        id:progressBar
        visible: false
        color: "transparent"
        border.width: 0
        anchors.fill: parent
        radius : 0
        Rectangle
        {
            id: progressBarInside
            width: statusBur.width
            height: 40
            color: "transparent"
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 15*screenScaleFactor
            Rectangle
            {
                id: idProgressOut
                height: 4*screenScaleFactor
                width: parent.width
                color: Constants.progressBarBgColor
                Rectangle
                {
                    id: idProgress
                    height: idProgressOut.height
                    color:"#1E9BE2"
                    anchors.left: idProgressOut.left
                }
            }


            StyledLabel
            {
                id:idSliceMessage
                width: 176*screenScaleFactor
                height: 18*screenScaleFactor
                text: qsTr("Processing, Please Wait...")
                color: "#ffffff"//Constants.textColor 深色浅色 字体一样
                font.pointSize: 16*screenScaleFactor
                font.family: Constants.labelFontFamilyBold
                anchors.horizontalCenter: progressBarInside.horizontalCenter
                anchors.bottom: idProgressOut.top
                anchors.bottomMargin: 5*screenScaleFactor
            }
        }


        BasicButton
        {
            id: cancelButton
            text: qsTr("cancel")
            width: 120*screenScaleFactor
            height: 28*screenScaleFactor
            btnRadius: height/2
            anchors.top: progressBarInside.bottom
            anchors.topMargin: 55*screenScaleFactor
            anchors.horizontalCenter: progressBarInside.horizontalCenter
            defaultBtnBgColor :Constants.leftToolBtnColor_normal
            hoveredBtnBgColor : Constants.leftToolBtnColor_hovered
            onSigButtonClicked:
            {
                if(object) object.stop()
                cancelJobButton()
                //kernel_kernel.setKernelPhase(0)
            }
        }

    }

    Rectangle
    {
        id: idSavefinishShow
        objectName: "SavefinishShow"
        anchors.right: statusBur.right
        anchors.rightMargin: 0
        height: parent.height
        width: 400
        color: "transparent"
        visible: false
        StyledLabel
        {
            id:idFirstMessage
            x:0
            y:5
            width: contentWidth
            height: idSavefinishShow.height
            text: qsTr("Save Finish")
            color: Constants.textColor
        }
        StyledLabel
        {
            id : idSecondMessage
            anchors.left: idFirstMessage.right
            anchors.leftMargin: 5
            y:5
            text: qsTr("Open fileDir")
            width: contentWidth
            height: idSavefinishShow.height
            font.underline: true
            color: "#3968E9"

            MouseArea
            {
                anchors.fill: parent
                onClicked:
                {
                    acceptButton()
                }
            }
        }
        Button
        {
            id: cancelButton2
            text: qsTr(" X ")
            width:40
            height: idSavefinishShow.height
            anchors.right: idSavefinishShow.right
            font.family: Constants.labelFontFamily
            font.weight: Constants.labelFontWeight
            onClicked:
            {
                idSavefinishShow.visible = false
            }
        }
    }

    Item
    {
        id: idMessShow
        anchors.right: statusBur.right
        anchors.rightMargin: 0
        height: parent.height
        width: idMessage.width + 60
        //        color: "transparent"
        visible: false
        property var receiver
        property alias textMess : idMessage.text
        StyledLabel
        {
            id:idMessage
            x:0
            y:5
            width: contentWidth
            height: idMessShow.height
            //   text: textMess
            color: Constants.textColor
        }

        Button
        {
            id: cancelBtn
            text: qsTr(" X ")
            width:40
            height: idMessShow.height
            anchors.right: idMessShow.right
            font.family: Constants.labelFontFamily
            font.weight: Constants.labelFontWeight
            onClicked:
            {
                idMessShow.visible = false
            }
        }
    }

    BasicMessageDialog
    {
        id: idopenFileMessageDlg
        objectName: "openFileMessageDlg"
        onAccept:
        {
            acceptButton()
        }
        onCancel:
        {
            //do nothing
        }
    }


    function jobsStart()
    {
        if(showProcess == true)
        {
            sigJobStart()
            statusBur.visible = true
            progressBar.visible = true
            cancelButton.visible = true
            idProgress.width = 0
            idSavefinishShow.visible = false
            /*idAdaptShow.visible = false*/
            controlEnabled(false)
        }
    }

    function jobsEnd()
    {
        sigJobEnd()
        statusBur.visible = false
        progressBar.visible = false
        cancelButton.visible = false
        controlEnabled(true)
    }

    function jobStart(details)
    {
        if(details.get("name")== "LoginJob" || details.get("name")== "AutoSaveJob")
        {
            console.log("LoginJob no need to show statusBar")
            statusBur.visible = false
            showProcess = false
        }
        else
        {
            statusBur.visible = true
            showProcess = true
        }
        idProgress.width = 0
        controlEnabled(false)
    }

    function jobEnd(details)
    {
        //idJob.text = details.get("status")
        controlEnabled(true)
    }

    function jobProgress(r)
    {
        idProgress.width = r * idProgressOut.width//(progressBar.width-160)
        //console.log("idProgress.width r= " + r )
    }

    function showMessage(mess1,btnMess)
    {
        idopenFileMessageDlg.showDoubleBtn()
        idopenFileMessageDlg.isInfo = true
        idopenFileMessageDlg.messageText = mess1 + btnMess
        idopenFileMessageDlg.show()
    }

    function bind(bindObject)
    {
        object = bindObject
        //console.log(object)
        object.jobsStart.connect(jobsStart)
        object.jobsEnd.connect(jobsEnd)
        object.jobStart.connect(jobStart)
        //object.jobEnd.connect(jobEnd)
        object.jobProgress.connect(jobProgress)
    }

    function showJobFinishMessage(receiver,textMessage)
    {
        console.log("receiver =" + receiver)
        //idMessShow.textMess = textMessage
        console.log("idMessShow.textMess =" + idMessShow.textMess)
        //idMessShow.visible = true
        idMessShow.receiver = receiver
    }

    function controlEnabled(bEnabled)
    {
        if(!Constants.bIsWizardShowing)
        {
            Constants.bLeftToolBarEnabled = bEnabled
            Constants.bRightPanelEnabled = bEnabled
            Constants.bMenuBarEnabled = bEnabled
            Constants.bGLViewEnabled = bEnabled
        }
    }
}

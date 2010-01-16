var KFC150 = {
    new : func() {
        var m = {parents:[KFC150]};

        m.AP_off=props.globals.getNode("autopilot/locks/passive-mode",1);
        m.AP_off.setBoolValue(1);
        m.flasher=0;
        m.self_test_enabled=0;
        m.self_test_timer=0;
        m.AP={off:1,on:0};
        m.LMlist=["wing-leveler","dg-heading-hold","nav1-hold","gps-hold"];
        m.VMlist=["pitch-hold","altitude-hold","gs1-hold"];

        m.Lateral_mode=props.globals.getNode("autopilot/locks/heading",1);
        m.Lateral_mode.setValue(m.LMlist[0]);

        m.Vertical_mode=props.globals.getNode("autopilot/locks/altitude",1);
        m.Vertical_mode.setValue(m.VMlist[0]);

        m.Pitch_setting=props.globals.getNode("autopilot/settings/target-pitch-deg",1);
        m.Pitch_setting.setDoubleValue(0);

        m.KFCnode = props.globals.getNode("instrumentation/kfc150",1);
        m.self_test_passed= m.KFCnode.getNode("self-test-passed",1);
        m.self_test_passed.setBoolValue(0);
        m.aural_tone=m.KFCnode.getNode("aural-tone",1);
        m.aural_tone.setBoolValue(0);
        m.FD_annun=m.KFCnode.getNode("annunciators/fd",1);
        m.FD_annun.setBoolValue(0);
        m.ALT_annun=m.KFCnode.getNode("annunciators/alt",1);
        m.ALT_annun.setBoolValue(0);
        m.HDG_annun=m.KFCnode.getNode("annunciators/hdg",1);
        m.HDG_annun.setBoolValue(0);
        m.NAV_annun=m.KFCnode.getNode("annunciators/nav",1);
        m.NAV_annun.setBoolValue(0);
        m.APR_annun=m.KFCnode.getNode("annunciators/apr",1);
        m.APR_annun.setBoolValue(0);
        m.BC_annun=m.KFCnode.getNode("annunciators/bc",1);
        m.BC_annun.setBoolValue(0);
        m.TRIM_annun=m.KFCnode.getNode("annunciators/trim-fail",1);
        m.TRIM_annun.setBoolValue(0);
        m.AP_annun=m.KFCnode.getNode("annunciators/AP",1);
        m.AP_annun.setBoolValue(0);

        return m;
    },
#### AP loop ####
    AP_update : func(){
        var Ln = me.Lateral_mode.getValue();
        var Vn= me.Vertical_mode.getValue();
        if(Vn == "gs1-hold")me.APR_annun.setValue(1) else me.APR_annun.setValue(me.flasher);
        if(Vn == "altitude-hold")me.ALT_annun.setValue(1) else me.ALT_annun.setValue(me.flasher);
        if(Ln == "dg-heading-hold")me.HDG_annun.setValue(1) else me.HDG_annun.setValue(me.flasher);
        if(Ln == "nav1-hold" or Ln=="gps-hold")me.NAV_annun.setValue(1) else me.NAV_annun.setValue(me.flasher);
        if(getprop("instrumentation/nav/back-course-btn"))me.BC_annun.setValue(1) else me.BC_annun.setValue(me.flasher);
        if(!me.AP_off.getValue())me.AP_annun.setValue(1) else me.AP_annun.setValue(me.flasher);;
        if(me.self_test_enabled !=0) me.self_test_loop();
    },
#### Button press ####
    set_mode : func(md){
        var Ln = me.Lateral_mode.getValue();
        var Vn= me.Vertical_mode.getValue();

        if(md=="test"){
            if(!me.self_test_passed.getValue()){
                me.self_test_enabled=1;
            }
        }elsif(md=="pitch-up"){
            if(Vn=="pitch-hold"){
                var ptch = me.Pitch_setting.getValue();
                ptch +=0.1;
                if(ptch>30)ptch=30;
                me.Pitch_setting.setValue(ptch);
            }
        }elsif(md=="pitch-down"){
            if(Vn=="pitch-hold"){
                var ptch = me.Pitch_setting.getValue();
                ptch -=0.1;
                if(ptch<-30)ptch=-30;
                me.Pitch_setting.setValue(ptch);
            }
        }elsif(md=="fd"){
            var fd = me.FD_annun.getValue();
            fd=1-fd;
            me.FD_annun.setValue(fd);
        }elsif(md=="alt"){
            if(Vn == me.VMlist[1]){
                me.Vertical_mode.setValue(me.VMlist[0]); 
            }else {
                me.Vertical_mode.setValue(me.VMlist[1]);
                setprop("autopilot/settings/target-altitude-ft",getprop("position/altitude-ft"));
            }
        }elsif(md=="hdg"){
            if(Ln == me.LMlist[1])me.Lateral_mode.setValue(me.LMlist[0]) else me.Lateral_mode.setValue(me.LMlist[1]);
        }elsif(md=="nav"){
            if(Ln == me.LMlist[0]){
                me.Lateral_mode.setValue(me.LMlist[2]);
            }elsif(Ln == me.LMlist[2]){
                me.Lateral_mode.setValue(me.LMlist[3]);
            }else{
                me.Lateral_mode.setValue(me.LMlist[0]);
            }
        }elsif(md=="apr"){
            if(Ln == me.LMlist[2])me.Lateral_mode.setValue(me.LMlist[0]) else me.Lateral_mode.setValue(me.LMlist[2]);
            if(Vn == me.VMlist[2])me.Vertical_mode.setValue(me.VMlist[0]) else me.Vertical_mode.setValue(me.VMlist[2]);
        }elsif(md=="AP"){
            var AP = me.AP_off.getValue();
            if(me.self_test_passed.getValue()){
                AP=1-AP;
                me.AP_off.setValue(AP);
            }else me.AP_off.setValue(me.AP.off);
        }
    },
#### Self test ####
    self_test_loop: func(){
        if(!me.self_test_passed.getValue()){
            me.self_test_timer +=1;
            me.flasher=1-me.flasher;
            if(me.self_test_timer >10){
                me.self_test_timer=0;
                me.self_test_enabled=0;
                me.self_test_passed.setValue(1);
                me.flasher=0;
            }
        }
    },
};

#############################################

var kfc150=KFC150.new();

setlistener("/sim/signals/fdm-initialized", func {
    settimer(kfc_update,5);
    print("KFC150 ... ok");
});

var kfc_update = func {
    kfc150.AP_update();
settimer(kfc_update, 0.5);
}

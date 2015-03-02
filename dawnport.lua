DP = {
  chatName    = "intRact",
  Dialog      = nil,
  onClose     = channelClose,
  dialogPos   = 1,
  vocation    = 0,
  stage       = 1,
  vochud      = nil,
  stagehud    = nil,
  levelhud    = nil,
  levelLeave  = 0,
  curDiag     = nil,
  updateStage = function(hud, txt)
    hud:SetText("Stage: " .. txt)
  end
}

Vocations = {"Knight", "Paladin", "Druid", "Sorcerer"}


Error = {
  non_numeric = "Please, type a number (1-4).",
  levelrange  = "The level must be from 8-21."
}

Stages = {
  {
    name = "Set vocation",
    main  = nil,
    complete = function()
      DP.vochud:SetText("Vocation: " .. Vocations[DP.vocation])
      DP.vochud:SetTextColor(0,255,125)
      DP.Dialog:SendOrangeMessage(DP.chatName,"Vocation chosen: " .. Vocations[DP.vocation])
      DialogPT2.trigger(DialogPT2)
    end
  },
  {
    name = "Set level",
    main = function()
      DP.vochud:SetText("Vocation: " .. Vocations[DP.vocation])
      DP.vochud:SetTextColor(0,255,125)
      DP.Dialog:SendOrangeMessage(DP.chatName,"Vocation chosen: " .. Vocations[DP.vocation])
      Stages.Update()
    end
  },
  {
  name = "Hunting part one",
  main = function()
    DP.Dialog:SendOrangeMessage(DP.chatName,"Starting walker.")
    Self.OpenMainBackpack(true)
    Walker.Goto("begin")
    Walker.Start()
    -- Stages.Update()
  end
  },
  {
    name = "Hunting part two",
    main = function()
      DP.Dialog:SendOrangeMessage(DP.chatName,"Part two.")
    --  Stages.Update()
    end
  },
  Update = function()
    DP.stage = DP.stage + 1
    DP.updateStage(DP.stagehud, "Yp")
    Stages[DP.stage].main()
  end
}

DialogPT1 = {
  "Hello! Let's take you to main in a jiffy",
  "What vocation do you want?",
  "[1] " .. Vocations[1],
  "[2] " .. Vocations[2],
  "[3] " .. Vocations[3],
  "[4] " .. Vocations[4],
  trigger = function (table)
    for i = 1, #table do
      DP.Dialog:SendYellowMessage(DP.chatName, table[i])
    end
  end,
  onTalk = function(c, msg)
    if (Vocations[tonumber(msg)] == nil) then
      DP.Dialog:SendOrangeMessage(DP.chatName,Error.non_numeric)
    else
      DP.vocation = tonumber(msg)
      Stages[DP.stage].complete();
    end
  end
}

DialogPT2 = {
  "Time to tell me which level do you want to leave at?",
    trigger = function (table)
      for i = 1, #table do
        DP.Dialog:SendYellowMessage(DP.chatName, table[i])
      end
    end,
    onTalk = function(c, msg)
      if (Vocations[tonumber(msg)] == nil) then
        DP.Dialog:SendOrangeMessage(DP.chatName,Error.non_numeric)
      elseif Vocations[tonumber(msg)] >= 8 and (Vocations[tonumber(msg)] <= 21) then
        DP.levelLeave = tonumber(msg)
        Stages[DP.stage].main();
      else
        DP.Dialog:SendOrangeMessage(DP.chatName,Error.levelrange)
      end
    end
    }

DP.Dialog = Channel.New(DP.chatName, DP.msgCallback, DP.onClose)
DialogPT1.trigger(DialogPT1);
DialogPT1.trigger

DP.vochud   = HUD.New(20, 40, "Vocation: none chosen.", 255, 0, 0)
DP.stagehud = HUD.New(20, 60, "Stage: " .. Stages[DP.stage].name, 255, 255, 100)
DP.levelhud = HUD.New(20, 60, "Level: " .. DP.levelLeave, 255, 255, 100)

registerEventListener(WALKER_SELECTLABEL, "labelSwitch")

function labelSwitch(label)
  if (label == round) then
    print("sup")
  end
end

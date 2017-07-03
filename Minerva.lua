-- https://www.townlong-yak.com/framexml/1.12.1/ChatFrame.lua#1784
ChatFrameEditBox.chatType = "GUILD";
ChatFrameEditBox.stickyType = "GUILD";

-- https://www.townlong-yak.com/framexml/1.12.1/GlobalStrings.lua#3486
SLASH_RL1 = "/rl";
-- https://www.townlong-yak.com/framexml/1.12.1/ChatFrame.lua#669
SlashCmdList["RL"] = function()
  ReloadUI();
end
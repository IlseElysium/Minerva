-- https://www.townlong-yak.com/framexml/1.12.1/ChatFrame.lua#1784
ChatFrameEditBox.chatType = "GUILD";
ChatFrameEditBox.stickyType = "GUILD";

-- https://www.townlong-yak.com/framexml/1.12.1/GlobalStrings.lua
MSG_GOLD = "Gold sellers thrive on compromised accounts and our tools for detecting gold buying and tracing gold and items are better than their techniques for preventing buyers from being banned. Help us thwart gold selling by enabling two-factor authentication on your account and by not supporting gold buying. Friends don't let friends buy gold.";

-- https://www.townlong-yak.com/framexml/1.12.1/GlobalStrings.lua#3486
SLASH_RL1 = "/rl";
-- https://www.townlong-yak.com/framexml/1.12.1/ChatFrame.lua#669
SlashCmdList["RL"] = function()
  ReloadUI();
end

-- https://www.townlong-yak.com/framexml/1.12.1/ChatFrame.lua#1260
local Original_ChatFrame_OnEvent = ChatFrame_OnEvent;
function ChatFrame_OnEvent(event)
  if ( event == "CHAT_MSG_SYSTEM" ) then
    if ( arg1 == MSG_GOLD ) then
      return;
    end
  end
  Original_ChatFrame_OnEvent(event);
end
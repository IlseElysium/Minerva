-- http://wowprogramming.com/docs/api/gmatch
function string.match(str, pattern)
  -- https://www.lua.org/pil/20.1.html
  local _, count = string.gsub(str, "^("..pattern..")$", "%1");
  -- https://www.lua.org/pil/3.3.html
  return count == 1 and true or false;
end

-- https://www.townlong-yak.com/framexml/1.12.1/GlobalStrings.lua
FILTER_GUILD_MOTD = true;
FILTER_SYSTEM_WELCOME = true;
FILTER_TICKETS = true;

GONAME = "Goname";

MSG_GOLD = "Gold sellers thrive on compromised accounts and our tools for detecting gold buying and tracing gold and items are better than their techniques for preventing buyers from being banned. Help us thwart gold selling by enabling two-factor authentication on your account and by not supporting gold buying. Friends don't let friends buy gold.";
MSG_WELCOME = "Welcome to the %s Pv[EP] Realm!";

SLASH_HOME1 = "/home";
SLASH_RL1 = "/rl";

-- http://wowwiki.wikia.com/wiki/AddOn_loading_process
local Frame = CreateFrame("Frame");
local Event = false;

Frame:RegisterEvent("SPELLS_CHANGED");
Frame:RegisterEvent("PLAYER_LOGIN");

Frame:SetScript("OnEvent", function()
  if ( event == "SPELLS_CHANGED" ) then
    Frame:UnregisterEvent("SPELLS_CHANGED");
    Event = true;
  elseif ( event == "PLAYER_LOGIN" ) then
    Frame:UnregisterEvent("SPELLS_CHANGED");
    Frame:UnregisterEvent("PLAYER_LOGIN");
    FILTER_GUILD_MOTD = false;
    if ( not Event ) then
      FILTER_SYSTEM_WELCOME = false;
    end
    SendChatMessage(".ticket list");
  end
end)

-- https://www.townlong-yak.com/framexml/1.12.1/UnitPopup.lua#12
UnitPopupButtons["GONAME"] = { text = TEXT(GONAME), dist = 0 };

-- https://www.townlong-yak.com/framexml/1.12.1/UnitPopup.lua#74
UnitPopupMenus["FRIEND"] = { "WHISPER", "INVITE", "TARGET", "GUILD_PROMOTE", "GUILD_LEAVE", "GONAME", "CANCEL" };

-- https://www.townlong-yak.com/framexml/1.12.1/UnitPopup.lua#261
local Original_UnitPopup_HideButtons = UnitPopup_HideButtons;
function UnitPopup_HideButtons()
  Original_UnitPopup_HideButtons();
  local dropdownMenu = getglobal(UIDROPDOWNMENU_INIT_MENU);
  for index, value in UnitPopupMenus[dropdownMenu.which] do
    if ( value == "GONAME" ) then
      if ( dropdownMenu.name == UnitName("player") ) then
        UnitPopupShown[index] = 0;
      end
    end
  end
end

-- https://www.townlong-yak.com/framexml/1.12.1/UnitPopup.lua#536
local Original_UnitPopup_OnClick = UnitPopup_OnClick;
function UnitPopup_OnClick()
  if ( this.value == "GONAME" ) then
    SendChatMessage(".goname "..FriendsDropDown.name);
  end
  Original_UnitPopup_OnClick();
end

-- https://www.townlong-yak.com/framexml/1.12.1/ChatFrame.lua#669
SlashCmdList["HOME"] = function()
  SendChatMessage(".go xyzo 971 561 210 2.9 37");
end

SlashCmdList["RL"] = function()
  ReloadUI();
end

-- https://www.townlong-yak.com/framexml/1.12.1/ChatFrame.lua#1260
local Original_ChatFrame_OnEvent = ChatFrame_OnEvent;
function ChatFrame_OnEvent(event)
  if ( event == "CHAT_MSG_SYSTEM" ) then
    if ( arg1 == MSG_GOLD ) then
      return;
    elseif ( string.match(arg1, format(MSG_WELCOME, GetRealmName())) and FILTER_SYSTEM_WELCOME ) then
      FILTER_SYSTEM_WELCOME = false;
      return;
    elseif ( arg1 == "Showing list of open tickets." ) then
      if ( TICKETS_AMMOUNT ) then
        FILTER_TICKETS = false;
      end
      TICKETS_AMMOUNT = 1;
      if ( FILTER_TICKETS ) then
        return;
      end
    elseif ( string.match(arg1, "|cffaaffaaTicket|r:|cffaaccff %d+%.|r |cff00ff00Creator|r:|cff00ccff |cffffffff|Hplayer:%a+|h%[%a+%]|h|r|r |cff00ff00Created|r:|cff00ccff [%d+0dhms]- ago|r.*") and not string.match(arg1, ".*Ticket Message.*") ) then
      local ticketNumber = string.gsub(arg1, "|cffaaffaaTicket|r:|cffaaccff (%d+).+", "%1");
      if ( TICKETS_AMMOUNT <= 12 ) then
        getglobal("MinervaButton"..TICKETS_AMMOUNT.."Ticket"):SetText(ticketNumber);
        if ( MinervaFrame.area and (tonumber((string.gsub(MinervaFrame.area:GetName(), "MinervaButton(%d+)", "%1"))) == TICKETS_AMMOUNT) ) then
          getglobal(MinervaFrame.area:GetName().."Background"):SetTexture(0.63671875, 0.1875, 0.1875);
          getglobal(MinervaFrame.area:GetName().."Border"):SetTexture(0, 0, 0);
        end
      end
      TICKETS_AMMOUNT = TICKETS_AMMOUNT + 1;
      if ( FILTER_TICKETS ) then
        return;
      end
    elseif ( string.match(arg1, "|cff00ff00New ticket from|r|cffff00ff %a+.|r |cff00ff00Ticket entry:|r|cffff00ff %d+.|r") ) then
      local ticketNumber = string.gsub(arg1, "|cff00ff00New ticket from|r|cffff00ff %a+.|r |cff00ff00Ticket entry:|r|cffff00ff (%d+).|r", "%1");
      if ( TICKETS_AMMOUNT <= 12 ) then
        getglobal("MinervaButton"..TICKETS_AMMOUNT.."Ticket"):SetText(ticketNumber);
      end
      TICKETS_AMMOUNT = TICKETS_AMMOUNT + 1;
    end
  elseif ( event == "GUILD_MOTD" ) then
    if ( FILTER_GUILD_MOTD ) then
      FILTER_GUILD_MOTD = false;
      return;
    end
  end
  Original_ChatFrame_OnEvent(event);
end

-- https://www.townlong-yak.com/framexml/1.12.1/ChatFrame.lua#1784
ChatFrameEditBox.chatType = "GUILD";
ChatFrameEditBox.stickyType = "GUILD";
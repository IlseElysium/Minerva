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
TICKETS = {};

GONAME = "Goname";

MSG_GOLD = "Gold sellers thrive on compromised accounts and our tools for detecting gold buying and tracing gold and items are better than their techniques for preventing buyers from being banned. Help us thwart gold selling by enabling two-factor authentication on your account and by not supporting gold buying. Friends don't let friends buy gold.";
MSG_WELCOME = "Welcome to the %s Pv[EP] Realm!";

SLASH_HOME1 = "/home";
SLASH_RL1 = "/rl";

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

function removeTicket(ticketNumber)
  for key, value in pairs(TICKETS) do
    if TICKETS[key]["number"] == ticketNumber then
      table.remove(TICKETS, key);
      if ( key <= 12 ) then
        for i = key, 12 do
          if ( i < table.getn(TICKETS) + 1 ) then
            getglobal("MinervaButton"..i.."Ticket"):SetText(TICKETS[i]["number"]);
            getglobal("MinervaButton"..i.."Owner"):SetText(TICKETS[i]["owner"]);
          elseif ( i == table.getn(TICKETS) + 1 ) then
            getglobal("MinervaButton"..i.."Ticket"):SetText("");
            getglobal("MinervaButton"..i.."Owner"):SetText("");
          end
        end
      end
      break
    end
  end
end

-- https://www.townlong-yak.com/framexml/1.12.1/ChatFrame.lua#1260
local Original_ChatFrame_OnEvent = ChatFrame_OnEvent;
function ChatFrame_OnEvent(event)
  if ( event == "CHAT_MSG_SYSTEM" ) then
    if ( arg1 == MSG_GOLD ) then
      return;
    elseif ( string.match(arg1, format(MSG_WELCOME, GetRealmName())) and FILTER_SYSTEM_WELCOME or string.match(arg1, "Welcome to the test realm!") ) then
      FILTER_SYSTEM_WELCOME = false;
      return;
    elseif ( arg1 == "Showing list of open tickets." ) then
      if ( MinervaFrame.filter ) then
        FILTER_TICKETS = false;
      end
      MinervaFrame.filter = true;
      if ( FILTER_TICKETS ) then
        return;
      end
      ChatFrame1:AddMessage('|cffE74C3C[Ticket]|r list of all tickets:')
      return
    elseif ( arg1 == "Showing list of open tickets whose creator is online." ) then
      if ( MinervaFrame.filter ) then
        FILTER_TICKETS = false;
      end
      MinervaFrame.filter = true;
      ChatFrame1:AddMessage('|cffE74C3C[Ticket]|r list of online tickets:')
      return
    elseif ( string.match(arg1, "|cffaaffaaTicket|r:|cffaaccff %d+%.|r |cff00ff00Creator|r:|cff00ccff |cffffffff|Hplayer:%a+|h%[%a+%]|h|r|r |cff00ff00Created|r:|cff00ccff [%d+0dhms]- ago|r.*") and not string.match(arg1, ".*Ticket Message.*") and FILTER_TICKETS ) then
      local ticketNumber = string.gsub(arg1, "^|cffaaffaaTicket|r:|cffaaccff (%d+).+", "%1");
      local ticketOwner = string.gsub(arg1, "^|cffaaffaaTicket|r:|cffaaccff %d+%.|r |cff00ff00Creator|r:|cff00ccff |cffffffff|Hplayer:(%a+).+", "%1");
      local index = table.getn(TICKETS) + 1
      TICKETS[index] = { number = ticketNumber, owner = ticketOwner };
      if ( index <= 12 ) then
        getglobal("MinervaButton"..index.."Ticket"):SetText(ticketNumber);
        getglobal("MinervaButton"..index.."Owner"):SetText(ticketOwner);
        if ( MinervaFrame.area and (tonumber((string.gsub(MinervaFrame.area:GetName(), "MinervaButton(%d+)", "%1"))) == index) ) then
          getglobal(MinervaFrame.area:GetName().."Background"):SetTexture(0.63671875, 0.1875, 0.1875);
          getglobal(MinervaFrame.area:GetName().."Border"):SetTexture(0, 0, 0);
        end
      end
      if ( FILTER_TICKETS ) then
        return;
      end
    elseif ( string.match(arg1, "|cff00ff00New ticket from|r|cffff00ff %a+%.|r |cff00ff00Category:|r|cffff00ff %a+%.|r |cff00ff00Ticket entry:|r|cffff00ff %d+%.|r") ) then
      local ticketNumber = string.gsub(arg1, "^|cff00ff00New ticket from|r|cffff00ff %a+%.|r |cff00ff00Category:|r|cffff00ff %a+%.|r |cff00ff00Ticket entry:|r|cffff00ff (%d+)%.|r$", "%1");
      local ticketOwner = string.gsub(arg1, "^|cff00ff00New ticket from|r|cffff00ff (%a+)%.|r |cff00ff00Category:|r|cffff00ff %a+%.|r |cff00ff00Ticket entry:|r|cffff00ff %d+%.|r$", "%1");
      local index = table.getn(TICKETS) + 1
      table.insert(TICKETS, { number = ticketNumber, owner = ticketOwner })
      if ( table.getn(TICKETS) + 1 <= 12 ) then
        getglobal("MinervaButton"..index.."Ticket"):SetText(ticketNumber);
        getglobal("MinervaButton"..index.."Owner"):SetText(ticketOwner);
      end
      ChatFrame1:AddMessage('|cffE74C3C[Ticket]|r '..ticketNumber..' created by '..ticketOwner)
      return
    elseif ( string.match(arg1, "|cff00ff00Character|r|cffff00ff %a+ |r|cff00ff00edited their ticket. Ticket entry:|r|cffff00ff %d+%.|r") ) then
      local ticketNumber = string.gsub(arg1, "^|cff00ff00Character|r|cffff00ff %a+ |r|cff00ff00edited their ticket. Ticket entry:|r|cffff00ff (%d+)%.|r$", "%1");
      local ticketOwner = string.gsub(arg1, "^|cff00ff00Character|r|cffff00ff (%a+) |r|cff00ff00edited their ticket. Ticket entry:|r|cffff00ff %d+%.|r$", "%1");
      ChatFrame1:AddMessage('|cffE74C3C[Ticket]|r '..ticketNumber..' edited by '..ticketOwner)
      return
    elseif ( string.match(arg1, "|cffaaffaaTicket|r:|cffaaccff %d+%.|r |cff00ff00Creator|r:|cff00ccff %a+|r |cff00ff00Closed by|r:|cff00ccff %a+|r ") ) then
      local ticketNumber = string.gsub(arg1, "^|cffaaffaaTicket|r:|cffaaccff (%d+)%.|r |cff00ff00Creator|r:|cff00ccff %a+|r |cff00ff00Closed by|r:|cff00ccff %a+|r $", "%1");
      local ticketOwner = string.gsub(arg1, "^|cffaaffaaTicket|r:|cffaaccff %d+%.|r |cff00ff00Creator|r:|cff00ccff (%a+)|r |cff00ff00Closed by|r:|cff00ccff %a+|r $", "%1");
      local ticketCloser = string.gsub(arg1, "^|cffaaffaaTicket|r:|cffaaccff %d+%.|r |cff00ff00Creator|r:|cff00ccff %a+|r |cff00ff00Closed by|r:|cff00ccff (%a+)|r $", "%1");
      removeTicket(ticketNumber)
      ChatFrame1:AddMessage('|cffE74C3C[Ticket]|r '..ticketNumber..' from '..ticketOwner..' closed by '..ticketCloser)
      return
    elseif ( string.match(arg1, "|cff00ff00Character|r|cffff00ff %a+ |r|cff00ff00abandoned their ticket. Ticket entry:|r|cffff00ff %d+%.|r") ) then
      local ticketNumber = string.gsub(arg1, "^|cff00ff00Character|r|cffff00ff %a+ |r|cff00ff00abandoned their ticket. Ticket entry:|r|cffff00ff (%d+)%.|r$", "%1");
      local ticketOwner = string.gsub(arg1, "^|cff00ff00Character|r|cffff00ff (%a+) |r|cff00ff00abandoned their ticket. Ticket entry:|r|cffff00ff %d+%.|r$", "%1");
      removeTicket(ticketNumber)
      ChatFrame1:AddMessage('|cffE74C3C[Ticket]|r '..ticketNumber..' deleted by '..ticketOwner)
      return
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
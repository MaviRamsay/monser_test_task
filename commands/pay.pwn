CMD:pay (playerid, const params[])
{
	extract params -> new player: iTargetId, iMoney; else return SendClientMessage(playerid, -1, !"Введите: /pay [id] [сумма]");
	
	new iUnixNow = gettime();

	if (iMoney <= 0) {
		return SendClientMessage(playerid, -1, !"Введена неверная сумма"); 
	}
	else if (!IsPlayerConnected(iTargetId)) {
		return SendClientMessage(playerid, -1, !"Игрока нет в сети");
	}
	else if (aPlayerInfo[playerid][pMoney] < iMoney) {
		return SendClientMessage(playerid, -1, !"Недостаточно средств");
	}
	else if (aPlayerInfo[playerid][pLastMoneyTransferRestriction] > iUnixNow) {
		static const fmt_str[] = "[Ошибка] У Вас ограничение на перевод денег. Следующий трансфер через %d секунд(-ы)";
		new szErrorMessage[sizeof fmt_str - 2 + 3];

		format(szErrorMessage, sizeof szErrorMessage, fmt_str, aPlayerInfo[playerid][pLastMoneyTransferRestriction] - iUnixNow);
		SendClientMessage(playerid, -1, szErrorMessage);
	}
	else {
		aPlayerInfo[playerid][pMoney] -= iMoney;
		aPlayerInfo[iTargetId][pMoney] += iMoney;

		GivePlayerMoney(iTargetId, iMoney);
		GivePlayerMoney(playerid, -iMoney);

		aPlayerInfo[playerid][pSeansTransferedMoney] += iMoney;
		aPlayerInfo[playerid][pLastMoneyTransferRestriction] = iUnixNow + GetTransferRestriction(aPlayerInfo[playerid][pSeansTransferedMoney]);

		if (aPlayerInfo[playerid][pMoneyTimer] == INVALID_TIMER_ID) {
			aPlayerInfo[playerid][pMoneyTimer] = SetPlayerTimerEx(playerid, !"OnPlayerMoneyTimerElapsed", 1000 * 60 * 10, false, !"d", playerid);
		}

		static const sender_fmt_str[] = "{42AAFF}Вы перевели %d$ игроку %s";
		static const recipient_fmt_str[] = "{42AAFF}Игрок %s перевел Вам %d$ !";

		new szSuccessMessage[sizeof recipient_fmt_str - 4 + MAX_PLAYER_NAME + 6];

		format(szSuccessMessage, sizeof szSuccessMessage, sender_fmt_str, iMoney, aPlayerInfo[iTargetId][pName]);
		SendClientMessage(playerid, -1, szSuccessMessage);

		format(szSuccessMessage, sizeof szSuccessMessage, recipient_fmt_str, aPlayerInfo[playerid][pName], iMoney);
		SendClientMessage(iTargetId, -1, szSuccessMessage);
	}

	return 1;
}

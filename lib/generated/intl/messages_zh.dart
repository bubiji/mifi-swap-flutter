// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  static String m0(value) => "添加 ${value} 地址";

  static String m1(value) => "已隱藏 ${value}";

  static String m2(value) => "已顯示 ${value}";

  static String m6(value) => "刪除 ${value} 地址";

  static String m7(value) => "充值到賬至少需要 ${value} 個區塊確認";

  static String m8(value) => "地址和 Memo(備註)同時使用才能充值 ${value} 到你的賬戶。";

  static String m9(value) => "首次充值至少 ${value}";

  static String m10(value) => "該充值地址僅支持 ${value}.";

  static String m11(arg0) => "錯誤 20124：手續費不足。請確保錢包至少有 ${arg0} 當作手續費。";

  static String m12(arg0, arg1) =>
      "錯誤 30102：地址格式錯誤。請輸入正確的 ${arg0} ${arg1} 的地址！";

  static String m13(arg0) => "錯誤 10006：請更新 Mixin（${arg0}） 至最新版。";

  static String m14(count, arg0) =>
      "${Intl.plural(count, one: '錯誤 20119：PIN 不正確。你還有 ${arg0} 次機會，使用完需等待 24 小時後再次嘗試。', other: '錯誤 20119：PIN 不正確。你還有 ${arg0} 次機會，使用完需等待 24 小時後再次嘗試。')}";

  static String m15(arg0) => "服務器出錯，請稍後重試：${arg0}";

  static String m16(arg0) => "錯誤：${arg0}";

  static String m17(arg0) => "錯誤：${arg0}";

  static String m18(value, value2) => "${value}/${value2} 區塊確認數";

  static String m19(value) => "請求付款金額: ${value}";

  static String m20(value) => "發送給 ${value}";

  static String m21(value) => "暫不支持滑點大於 ${value} 的閃兌";

  static String m22(value) => "價值 ${value}";

  static String m23(value) => "當時價值 ${value}";

  static String m24(value) => "提現到 ${value}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "AddAsset": MessageLookupByLibrary.simpleMessage("添加資產"),
        "accessDenied": MessageLookupByLibrary.simpleMessage("禁止訪問"),
        "addAddress": MessageLookupByLibrary.simpleMessage("添加地址"),
        "addAddressByPinTip":
            MessageLookupByLibrary.simpleMessage("請輸入 PIN 來完成添加"),
        "addAddressLabelHint":
            MessageLookupByLibrary.simpleMessage("地址名稱，例如 OceanOne"),
        "addAddressMemo":
            MessageLookupByLibrary.simpleMessage("地址備註、數字 ID 或備註。如果沒有，"),
        "addAddressMemoAction":
            MessageLookupByLibrary.simpleMessage("點擊不使用備註（Memo）"),
        "addAddressNoMemo":
            MessageLookupByLibrary.simpleMessage("如果你需要填寫地址備註、數字 ID 或備註，"),
        "addAddressNoMemoAction":
            MessageLookupByLibrary.simpleMessage("點擊添加備註（Memo）"),
        "addAddressNoTagAction":
            MessageLookupByLibrary.simpleMessage("點擊添加標籤（Tag）"),
        "addAddressNotSupportTip":
            MessageLookupByLibrary.simpleMessage("Mixin 不支持提現到"),
        "addAddressTagAction":
            MessageLookupByLibrary.simpleMessage("點擊不使用標籤（Tag）"),
        "addWithdrawalAddress": m0,
        "address": MessageLookupByLibrary.simpleMessage("地址"),
        "addressSearchHint": MessageLookupByLibrary.simpleMessage("標題，地址"),
        "allAssets": MessageLookupByLibrary.simpleMessage("所有幣種"),
        "allTransactions": MessageLookupByLibrary.simpleMessage("所有交易"),
        "alreadyHidden": m1,
        "alreadyShown": m2,
        "amount": MessageLookupByLibrary.simpleMessage("金額"),
        "and": MessageLookupByLibrary.simpleMessage("和"),
        "assetAddressGeneratingTip":
            MessageLookupByLibrary.simpleMessage("資產地址正在生成中，請稍後..."),
        "assetTrending": MessageLookupByLibrary.simpleMessage("熱門資產"),
        "assetType": MessageLookupByLibrary.simpleMessage("資產類型"),
        "assets": MessageLookupByLibrary.simpleMessage("資產"),
        "authHint": MessageLookupByLibrary.simpleMessage("只讀授權無法動用你的資產，請放心使用"),
        "authSlogan": MessageLookupByLibrary.simpleMessage(
            "Mixin 錢包是一款用戶友好、安全且功能強大的多鏈數字錢包。"),
        "authTips":
            MessageLookupByLibrary.simpleMessage("你知道嗎？Mixin 是一個開源的加密錢包"),
        "authorize": MessageLookupByLibrary.simpleMessage("使用 Mixin 登錄"),
        "balance": MessageLookupByLibrary.simpleMessage("餘額"),
        "buy": MessageLookupByLibrary.simpleMessage("購買"),
        "buyDisclaimer": MessageLookupByLibrary.simpleMessage(
            "購買服務由 https://sendwyre.com 提供"),
        "cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "chain": MessageLookupByLibrary.simpleMessage("所屬公鏈"),
        "checkbalance": MessageLookupByLibrary.simpleMessage("檢查餘額"),
        "clearConditions": MessageLookupByLibrary.simpleMessage("清除條件"),
        "coins": MessageLookupByLibrary.simpleMessage("代幣"),
        "comingSoon": MessageLookupByLibrary.simpleMessage("即將推出"),
        "completed": MessageLookupByLibrary.simpleMessage("已完成"),
        "confirm": MessageLookupByLibrary.simpleMessage("確認"),
        "confirmation": MessageLookupByLibrary.simpleMessage("確認"),
        "connectinfo": MessageLookupByLibrary.simpleMessage("連接賬號代表您同意"),
        "contact": MessageLookupByLibrary.simpleMessage("聯繫人"),
        "contactReadFailed": MessageLookupByLibrary.simpleMessage("讀取聯繫人列表失敗"),
        "contactSearchHint":
            MessageLookupByLibrary.simpleMessage("名稱, Mixin ID"),
        "continueText": MessageLookupByLibrary.simpleMessage("繼續"),
        "contract": MessageLookupByLibrary.simpleMessage("資產標識"),
        "copyLink": MessageLookupByLibrary.simpleMessage("複製鏈接"),
        "copyToClipboard": MessageLookupByLibrary.simpleMessage("已復製到剪切板"),
        "createAccount": MessageLookupByLibrary.simpleMessage("創建賬號"),
        "createPin": MessageLookupByLibrary.simpleMessage("創建 PIN"),
        "createPinTips":
            MessageLookupByLibrary.simpleMessage("創建 PIN 以保護您的賬戶安全"),
        "createtradingOrder": MessageLookupByLibrary.simpleMessage("創建交易訂單"),
        "customDateRange": MessageLookupByLibrary.simpleMessage("自定義日期範圍"),
        "date": MessageLookupByLibrary.simpleMessage("日期"),
        "dateRange": MessageLookupByLibrary.simpleMessage("日期範圍"),
        "delete": MessageLookupByLibrary.simpleMessage("刪除"),
        "deleteAddressByPinTip":
            MessageLookupByLibrary.simpleMessage("請輸入 PIN 來完成刪除"),
        "deleteWithdrawalAddress": m6,
        "deposit": MessageLookupByLibrary.simpleMessage("充值"),
        "depositConfirmation": m7,
        "depositMemoNotice": MessageLookupByLibrary.simpleMessage(
            "提幣時務必填寫 Memo(備註)，否則您會丟失您的數字幣"),
        "depositNotice": m8,
        "depositReserve": m9,
        "depositTip": m10,
        "depositTipBtc": MessageLookupByLibrary.simpleMessage("該充值地址僅支持 BTC。"),
        "depositTipEos":
            MessageLookupByLibrary.simpleMessage("該充值地址支持所有基於 EOS 發行的代幣。"),
        "depositTipEth": MessageLookupByLibrary.simpleMessage(
            "該充值地址支持所有符合 ERC-20 的代幣，例如 XIN 等。"),
        "depositTipNotSupportContract":
            MessageLookupByLibrary.simpleMessage("不支持合約充值。"),
        "depositTipTron": MessageLookupByLibrary.simpleMessage(
            "該充值地址支持 TRX 和所有符合 TRC-10 TRC-20 標準的代幣。"),
        "depositing": MessageLookupByLibrary.simpleMessage("充值中"),
        "dontShowAgain": MessageLookupByLibrary.simpleMessage("不再提醒"),
        "download": MessageLookupByLibrary.simpleMessage("下載"),
        "downloadMixinMessengerHint":
            MessageLookupByLibrary.simpleMessage("還未安裝 Mixin Messenger?"),
        "emptyAmount": MessageLookupByLibrary.simpleMessage("金額不能為空"),
        "emptyLabelOrAddress":
            MessageLookupByLibrary.simpleMessage("地址和標題不能為空"),
        "eosContractAddress": MessageLookupByLibrary.simpleMessage("EOS 合約地址"),
        "errorAuthentication":
            MessageLookupByLibrary.simpleMessage("錯誤 401：請重新登錄"),
        "errorBadData":
            MessageLookupByLibrary.simpleMessage("錯誤 10002：請求數據不合法"),
        "errorBlockchain":
            MessageLookupByLibrary.simpleMessage("錯誤 30100：區塊鏈同步異常，請稍後重試"),
        "errorConnectionTimeout":
            MessageLookupByLibrary.simpleMessage("網絡連接超時"),
        "errorFullGroup": MessageLookupByLibrary.simpleMessage("錯誤 20116：群組已滿"),
        "errorInsufficientBalance":
            MessageLookupByLibrary.simpleMessage("錯誤 20117：餘額不足"),
        "errorInsufficientTransactionFeeWithAmount": m11,
        "errorInvalidAddress": m12,
        "errorInvalidAddressPlain":
            MessageLookupByLibrary.simpleMessage("錯誤 30102：地址格式錯誤。"),
        "errorInvalidCodeTooFrequent":
            MessageLookupByLibrary.simpleMessage("錯誤 20129：發送驗證碼太頻繁，請稍後再試"),
        "errorInvalidEmergencyContact":
            MessageLookupByLibrary.simpleMessage("錯誤 20130：緊急聯繫人不正確"),
        "errorInvalidPinFormat":
            MessageLookupByLibrary.simpleMessage("錯誤 20118：PIN 格式不正確"),
        "errorNetworkTaskFailed":
            MessageLookupByLibrary.simpleMessage("網絡連接失敗。檢查或切換網絡，然後重試"),
        "errorNoCamera": MessageLookupByLibrary.simpleMessage("沒有相機"),
        "errorNoPinToken":
            MessageLookupByLibrary.simpleMessage("缺少憑據，請重新登錄之後再嘗試使用此功能。"),
        "errorNotFound":
            MessageLookupByLibrary.simpleMessage("錯誤 404：沒有找到相應的信息"),
        "errorNotSupportedAudioFormat":
            MessageLookupByLibrary.simpleMessage("不支持的音頻格式，請用其他app打開。"),
        "errorNumberReachedLimit":
            MessageLookupByLibrary.simpleMessage("錯誤 20132： 已達到上限"),
        "errorOldVersion": m13,
        "errorOpenLocation": MessageLookupByLibrary.simpleMessage("無法找到地圖應用"),
        "errorPermission": MessageLookupByLibrary.simpleMessage("請開啟相關權限"),
        "errorPhoneInvalidFormat":
            MessageLookupByLibrary.simpleMessage("錯誤 20110：手機號碼不合法"),
        "errorPhoneSmsDelivery":
            MessageLookupByLibrary.simpleMessage("錯誤 10003：發送短信失敗"),
        "errorPhoneVerificationCodeExpired":
            MessageLookupByLibrary.simpleMessage("錯誤 20114：驗證碼已過期"),
        "errorPhoneVerificationCodeInvalid":
            MessageLookupByLibrary.simpleMessage("錯誤 20113：驗證碼錯誤"),
        "errorPinCheckTooManyRequest": MessageLookupByLibrary.simpleMessage(
            "你已經嘗試了超過 5 次，請等待 24 小時後再次嘗試。"),
        "errorPinIncorrect":
            MessageLookupByLibrary.simpleMessage("錯誤 20119：PIN 不正確"),
        "errorPinIncorrectWithTimes": m14,
        "errorRecaptchaIsInvalid":
            MessageLookupByLibrary.simpleMessage("錯誤 10004：驗證失敗"),
        "errorServer5xxCode": m15,
        "errorTooManyRequest":
            MessageLookupByLibrary.simpleMessage("錯誤 429：請求過於頻繁"),
        "errorTooManyStickers":
            MessageLookupByLibrary.simpleMessage("錯誤 20126：貼紙數已達上限"),
        "errorTooSmallTransferAmount":
            MessageLookupByLibrary.simpleMessage("錯誤 20120：轉賬金額太小"),
        "errorTooSmallWithdrawAmount":
            MessageLookupByLibrary.simpleMessage("錯誤 20127：提現金額太小"),
        "errorTranscriptForward":
            MessageLookupByLibrary.simpleMessage("請在所有附件下載完成之後再轉發"),
        "errorUnableToOpenMedia":
            MessageLookupByLibrary.simpleMessage("無法找到能打開該媒體的應用"),
        "errorUnknownWithCode": m16,
        "errorUnknownWithMessage": m17,
        "errorUsedPhone":
            MessageLookupByLibrary.simpleMessage("錯誤 20122：電話號碼已經被佔用。"),
        "errorUserInvalidFormat":
            MessageLookupByLibrary.simpleMessage("用戶數據不合法"),
        "errorWithdrawalMemoFormatIncorrect":
            MessageLookupByLibrary.simpleMessage("錯誤 20131：提現備註格式不正確"),
        "export": MessageLookupByLibrary.simpleMessage("導出"),
        "exportTransactionsData":
            MessageLookupByLibrary.simpleMessage("導出交易數據"),
        "fee": MessageLookupByLibrary.simpleMessage("手續費"),
        "fees": MessageLookupByLibrary.simpleMessage("24h 手續費"),
        "filterAll": MessageLookupByLibrary.simpleMessage("全部"),
        "filterApply": MessageLookupByLibrary.simpleMessage("應用"),
        "filterBy": MessageLookupByLibrary.simpleMessage("篩選"),
        "filterTitle": MessageLookupByLibrary.simpleMessage("篩選"),
        "from": MessageLookupByLibrary.simpleMessage("來自"),
        "goPay": MessageLookupByLibrary.simpleMessage("去支付"),
        "gotIt": MessageLookupByLibrary.simpleMessage("知道了"),
        "hiddenAssets": MessageLookupByLibrary.simpleMessage("隱藏的資產"),
        "hide": MessageLookupByLibrary.simpleMessage("隱藏"),
        "hideSmallAssets": MessageLookupByLibrary.simpleMessage("隱藏小額資產"),
        "incomplete": MessageLookupByLibrary.simpleMessage("未完成"),
        "inputname": MessageLookupByLibrary.simpleMessage("請輸入賬號名稱"),
        "insufficientbalancePleasedeposit":
            MessageLookupByLibrary.simpleMessage("餘額不足"),
        "issueTime": MessageLookupByLibrary.simpleMessage("發佈時間"),
        "jumpingAdress": MessageLookupByLibrary.simpleMessage("正在跳轉到充值地址"),
        "lastNinetyDays": MessageLookupByLibrary.simpleMessage("最近 90 天"),
        "lastSevenDays": MessageLookupByLibrary.simpleMessage("最近 7 天"),
        "lastThirtyDays": MessageLookupByLibrary.simpleMessage("最近 30 天"),
        "linkGenerated": MessageLookupByLibrary.simpleMessage("鏈接已生成"),
        "liquidity": MessageLookupByLibrary.simpleMessage("流動性"),
        "loadding": MessageLookupByLibrary.simpleMessage("加載中..."),
        "local": MessageLookupByLibrary.simpleMessage("zh"),
        "marketCap": MessageLookupByLibrary.simpleMessage("市值"),
        "memo": MessageLookupByLibrary.simpleMessage("Memo(備註)"),
        "memoHint": MessageLookupByLibrary.simpleMessage("備註（Memo）"),
        "mifiswap": MessageLookupByLibrary.simpleMessage("MifiSwap"),
        "minRecevied": MessageLookupByLibrary.simpleMessage("至少獲得"),
        "minerFee": MessageLookupByLibrary.simpleMessage("挖礦手續費"),
        "minimumReserve": MessageLookupByLibrary.simpleMessage("最少保留數量："),
        "minimumWithdrawal": MessageLookupByLibrary.simpleMessage("最小提現數量："),
        "mixinWallet": MessageLookupByLibrary.simpleMessage("Mixin 錢包"),
        "myActivity": MessageLookupByLibrary.simpleMessage("記錄"),
        "myWallet": MessageLookupByLibrary.simpleMessage("我的"),
        "need": MessageLookupByLibrary.simpleMessage("需要"),
        "networkFee": MessageLookupByLibrary.simpleMessage("網絡手續費："),
        "networkFeeTip": MessageLookupByLibrary.simpleMessage(
            "由第三方服務商收取。直接支付給以太坊礦工以保證以太坊上交易完成。網絡費根據即時市場狀況變動。"),
        "networkType": MessageLookupByLibrary.simpleMessage("網絡類型"),
        "noAsset": MessageLookupByLibrary.simpleMessage("暫無資產"),
        "noLimit": MessageLookupByLibrary.simpleMessage("不限"),
        "noResult": MessageLookupByLibrary.simpleMessage("無結果"),
        "noTransaction": MessageLookupByLibrary.simpleMessage("暫無轉賬記錄"),
        "noWithdrawalDestinationSelected":
            MessageLookupByLibrary.simpleMessage("需要選擇一個聯繫人或地址"),
        "none": MessageLookupByLibrary.simpleMessage("暫無價格"),
        "notMeetMinimumAmount":
            MessageLookupByLibrary.simpleMessage("未能達到最低數額"),
        "notice": MessageLookupByLibrary.simpleMessage("注意"),
        "ok": MessageLookupByLibrary.simpleMessage("好的"),
        "other": MessageLookupByLibrary.simpleMessage("其他"),
        "overview": MessageLookupByLibrary.simpleMessage("概覽"),
        "paid": MessageLookupByLibrary.simpleMessage("已支付"),
        "paidInMixin":
            MessageLookupByLibrary.simpleMessage("您是否已經在 Mixin 中支付？"),
        "paidInMixinWarning":
            MessageLookupByLibrary.simpleMessage("如果您已經支付成功，請耐心等待，無需再次支付"),
        "pay": MessageLookupByLibrary.simpleMessage("支付"),
        "pendingConfirmations": m18,
        "pools": MessageLookupByLibrary.simpleMessage("流動池"),
        "price": MessageLookupByLibrary.simpleMessage("價格"),
        "priceImpact": MessageLookupByLibrary.simpleMessage("價格影響"),
        "privaryPolicy": MessageLookupByLibrary.simpleMessage("隱私條款"),
        "raw": MessageLookupByLibrary.simpleMessage("其他"),
        "rawTransaction": MessageLookupByLibrary.simpleMessage("交易原始值"),
        "reauthorize": MessageLookupByLibrary.simpleMessage("重新授權"),
        "rebate": MessageLookupByLibrary.simpleMessage("退款"),
        "receive": MessageLookupByLibrary.simpleMessage("接收"),
        "received": MessageLookupByLibrary.simpleMessage("獲得"),
        "receivers": MessageLookupByLibrary.simpleMessage("接收者"),
        "recentSearches": MessageLookupByLibrary.simpleMessage("最近搜索"),
        "refund": MessageLookupByLibrary.simpleMessage("退回"),
        "removeAuthorize": MessageLookupByLibrary.simpleMessage("取消授權"),
        "requestPayment": MessageLookupByLibrary.simpleMessage("請求付款"),
        "requestPaymentAmount": m19,
        "requestPaymentGeneratedTips":
            MessageLookupByLibrary.simpleMessage("請求付款鏈接已生成，請發送給指定聯繫人。"),
        "route": MessageLookupByLibrary.simpleMessage("兌換路徑"),
        "save": MessageLookupByLibrary.simpleMessage("保存"),
        "scanTopay": MessageLookupByLibrary.simpleMessage("掃碼支付"),
        "scanandpay": MessageLookupByLibrary.simpleMessage("掃描二維碼，並確認支付"),
        "search": MessageLookupByLibrary.simpleMessage("搜索"),
        "selectContactOrAddress":
            MessageLookupByLibrary.simpleMessage("選擇地址或聯繫人"),
        "send": MessageLookupByLibrary.simpleMessage("發送"),
        "sendLink": MessageLookupByLibrary.simpleMessage("發送鏈接"),
        "sendTo": m20,
        "sendToContact": MessageLookupByLibrary.simpleMessage("轉賬至聯繫人"),
        "setting": MessageLookupByLibrary.simpleMessage("設置"),
        "settings": MessageLookupByLibrary.simpleMessage("設置"),
        "show": MessageLookupByLibrary.simpleMessage("顯示"),
        "signTransaction": MessageLookupByLibrary.simpleMessage("簽名交易"),
        "signers": MessageLookupByLibrary.simpleMessage("簽名者"),
        "slippage": MessageLookupByLibrary.simpleMessage("滑點"),
        "slippageOver": m21,
        "snapshotHash": MessageLookupByLibrary.simpleMessage("Snapshot hash"),
        "sortBy": MessageLookupByLibrary.simpleMessage("排序"),
        "spiltfeeoutcome": MessageLookupByLibrary.simpleMessage("費用節省"),
        "spiltoutcome": MessageLookupByLibrary.simpleMessage("拆單收益"),
        "split": MessageLookupByLibrary.simpleMessage("拆單數量"),
        "splitswap": MessageLookupByLibrary.simpleMessage("拆單 & 閃兌"),
        "state": MessageLookupByLibrary.simpleMessage("State"),
        "submitTransaction": MessageLookupByLibrary.simpleMessage("提交交易"),
        "success": MessageLookupByLibrary.simpleMessage("成功"),
        "swap": MessageLookupByLibrary.simpleMessage("閃兌"),
        "swapDisclaimer":
            MessageLookupByLibrary.simpleMessage("服務由 MixSwap 提供"),
        "swapSuccessfully": MessageLookupByLibrary.simpleMessage("兌換成功!"),
        "swapType": MessageLookupByLibrary.simpleMessage("兌換幣種"),
        "swapfailed": MessageLookupByLibrary.simpleMessage("交易失敗"),
        "symbol": MessageLookupByLibrary.simpleMessage("符號"),
        "tagHint": MessageLookupByLibrary.simpleMessage("標籤（Tag）"),
        "termsOfService": MessageLookupByLibrary.simpleMessage("服務條款"),
        "time": MessageLookupByLibrary.simpleMessage("時間"),
        "times": MessageLookupByLibrary.simpleMessage("次"),
        "to": MessageLookupByLibrary.simpleMessage("至"),
        "totalBalance": MessageLookupByLibrary.simpleMessage("總餘額"),
        "totalLiquidity": MessageLookupByLibrary.simpleMessage("總流動性"),
        "totalSupply": MessageLookupByLibrary.simpleMessage("總供應量"),
        "trades": MessageLookupByLibrary.simpleMessage("24h 交易數"),
        "trading": MessageLookupByLibrary.simpleMessage("正在交易"),
        "transaction": MessageLookupByLibrary.simpleMessage("轉賬"),
        "transactionChecking": MessageLookupByLibrary.simpleMessage("檢查中"),
        "transactionDone": MessageLookupByLibrary.simpleMessage("完成"),
        "transactionFee": MessageLookupByLibrary.simpleMessage("交易費："),
        "transactionFeeTip": MessageLookupByLibrary.simpleMessage(
            "由第三方服務商收取。美國用戶按交易金額的2.9% + 30c收取，最低收費為\$5；國際用戶按交易金額的3.9% + 30c收取，最低收費為\$5。"),
        "transactionHash": MessageLookupByLibrary.simpleMessage("交易哈希"),
        "transactionPhase": MessageLookupByLibrary.simpleMessage("交易進度"),
        "transactionTrading": MessageLookupByLibrary.simpleMessage("交易中"),
        "transactions": MessageLookupByLibrary.simpleMessage("轉賬記錄"),
        "transactionsAssetKeyWarning":
            MessageLookupByLibrary.simpleMessage("資產標識不是充值地址！"),
        "transactionsId": MessageLookupByLibrary.simpleMessage("交易編號"),
        "transactionsStatus": MessageLookupByLibrary.simpleMessage("交易狀態"),
        "transactionsType": MessageLookupByLibrary.simpleMessage("交易類型"),
        "transfer": MessageLookupByLibrary.simpleMessage("轉賬"),
        "transferDetail": MessageLookupByLibrary.simpleMessage("交易詳情"),
        "trytopayforthextime": MessageLookupByLibrary.simpleMessage("嘗試支付第"),
        "turnover": MessageLookupByLibrary.simpleMessage("24h 換手率"),
        "type": MessageLookupByLibrary.simpleMessage("類型"),
        "undo": MessageLookupByLibrary.simpleMessage("撤銷"),
        "unpaid": MessageLookupByLibrary.simpleMessage("未支付"),
        "volume": MessageLookupByLibrary.simpleMessage("24h 交易量"),
        "waitforthedeposit": MessageLookupByLibrary.simpleMessage("等待充值"),
        "waitingActionDone": MessageLookupByLibrary.simpleMessage("等待操作完成..."),
        "walletImport": MessageLookupByLibrary.simpleMessage("導入KeyStore"),
        "walletTransactionCurrentValue": m22,
        "walletTransactionThatTimeNoValue":
            MessageLookupByLibrary.simpleMessage("當時價值 暫無"),
        "walletTransactionThatTimeValue": m23,
        "walletlogin": MessageLookupByLibrary.simpleMessage("創建錢包"),
        "walletlogout": MessageLookupByLibrary.simpleMessage("註銷錢包"),
        "website": MessageLookupByLibrary.simpleMessage("網址"),
        "wireServiceTip": MessageLookupByLibrary.simpleMessage(
            "本服務由 Wyre 提供。我們僅作為渠道，不額外收取手續費。"),
        "withdrawal": MessageLookupByLibrary.simpleMessage("提現"),
        "withdrawalMemoHint": MessageLookupByLibrary.simpleMessage("備註 (可選)"),
        "withdrawalTo": m24,
        "withdrawalWithPin": MessageLookupByLibrary.simpleMessage("用 PIN 提現"),
        "wyreServiceStatement": MessageLookupByLibrary.simpleMessage("服務聲明")
      };
}

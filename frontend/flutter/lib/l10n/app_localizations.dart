import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    _AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        (Localizations.localeOf(context).languageCode == 'zh'
            ? AppLocalizations(const Locale('zh'))
            : AppLocalizations(const Locale('en')));
  }

  static const Map<String, Map<String, String>> _localizedValues = <String, Map<String, String>>{
    'en': <String, String>{
      'appTitle': 'Nanookjaro Toolkit',
      'searchHint': 'Search or jump to...',
      'activityLog': 'Activity Log',
      'hideLog': 'Hide Log',
      'showLog': 'Activity Log',
      'quickActionsTitle': 'Quick Actions',
      'quickActionSystemUpgrade': 'Upgrade Wizard',
      'quickActionRollingUpgrade': 'Rolling Upgrade',
      'quickActionConfigureProxy': 'Proxy Dialog',
      'quickActionEnableProxy': 'Enable Proxy',
      'quickActionDisableProxy': 'Disable Proxy',
      'quickActionDriverScan': 'Driver Scan',
      'quickActionCleanCache': 'Clean Cache',
      'quickActionOpenLogs': 'Open Logs',
      'comingSoon': 'Coming soon',
      'rollingUpgradeRunning': 'Running pacman -Syu...',
      'rollingUpgradeSuccess': 'System upgrade completed successfully',
      'rollingUpgradeNeedsPassword':
          'Authentication required. Run the interactive command in a terminal.',
      'rollingUpgradeFailed': 'Upgrade failed (exit {code}). Check the log for details.',
    'rollingUpgradeError': 'Failed to run upgrade: {error}',
      'proxyApplySuccess': 'Proxy updated',
      'proxyApplyCleared': 'Proxy cleared',
      'proxyApplyFailed': 'Failed to update proxy: {error}',
    'proxyApplyProgress': 'Applying proxy settings...',
      'proxyDialogTitle': 'Configure Proxy',
      'proxyDialogDescription': 'Update the proxy environment variables for this session.',
      'proxyFieldHttp': 'http_proxy',
      'proxyFieldHttps': 'https_proxy',
      'cancel': 'Cancel',
      'apply': 'Apply',
      'systemOverviewTitle': 'System Overview',
      'loading': 'Loading...',
      'failedMetrics': 'Failed to load metrics: {error}',
      'updateStatusAllGood': 'All packages are up to date',
      'updateStatusPending': '{count} updates available',
      'updateStatusReboot': ' · reboot recommended',
      'upgradeNow': 'Upgrade Now',
      'updateCheckFailed': 'Update check failed: {error}',
      'filesystemTitle': 'Filesystem',
      'filesystemEmpty': 'No filesystem data available',
      'filesystemFailed': 'Failed to load filesystem info: {error}',
      'percentUsed': '{value}% used',
      'realtimeMetricsTitle': 'Realtime Metrics',
      'metricCurrent': 'Current',
      'metricLoad1m': 'Load 1 min',
      'metricSelected': 'Selected',
      'metricCpu': 'CPU',
      'metricMemory': 'Memory',
      'metricMemoryShort': 'RAM',
      'loadSnapshot': 'Load snapshot',
  'loadShort1': '1 min',
  'loadShort5': '5 min',
  'loadShort15': '15 min',
      'lastRefresh': 'Last Refresh',
      'proxyNone': 'No proxy configured',
      'proxyHttp': 'HTTP: {value}',
      'proxyHttps': 'HTTPS: {value}',
      'proxyBoth': 'HTTP: {http}\nHTTPS: {https}',
      'proxyMatch': '{value}',
      'cpuModel': 'CPU Model',
      'cpuCores': 'Cores/Threads',
      'cpuUsage': 'CPU Usage',
      'memory': 'Memory',
      'swap': 'Swap',
      'swapNotConfigured': 'not configured',
      'loadAverage': 'Load Average (1/5/15)',
      'gpu': 'GPU',
      'proxy': 'Proxy',
      'memoryUtilized': '{used} GB / {total} GB\n{percent}% utilized',
      'swapUtilized': '{used} GB / {total} GB\n{percent}% utilized',
      'logDrawerDescription':
          'Recent operations will appear here. Upgrade flows and driver actions will be logged with timestamps.',
      'proxyAutoYes': 'Auto confirm prompts (--noconfirm)',
      'proxyAutoYesSubtitle': 'Skip manual confirmations during the upgrade',
    'upgradeDescription':
      'Nanookjaro will attempt a non-interactive pacman -Syu. If sudo authentication is needed, you will be prompted to continue manually.',
      'runUpgrade': 'Run Upgrade',
      'close': 'Close',
      'retry': 'Retry',
      'cancelLower': 'Cancel',
      'copyCommand': 'Command copied to clipboard',
      'copyInteractive': 'Copy interactive command',
      'noOutput': '(no output)',
      'commandOutput': 'Command output',
      'nonInteractiveCommand': 'Non-interactive command: {command}',
      'interactiveCommand': 'Interactive command: {command}',
      'upgradeRunning': 'Running pacman -Syu...',
      'upgradeCompleted': 'Upgrade completed successfully',
      'upgradePasswordRequired': 'Password required to continue in terminal',
      'upgradeFailedExit': 'Upgrade failed (exit {code})',
      'upgradeInvokeFailed': 'Failed to invoke pacman upgrade',
      'upgradeDialogTitle': 'Run System Upgrade',
      'upgradeDialogResultTitle': 'Upgrade Result',
      'languageSystem': 'Follow system',
      'languageEnglish': 'English',
      'languageChinese': '中文',
      'languageMenu': 'Language',
      'proxyDialogLabel': 'Proxy Dialog',
      'floatingButtonShow': 'Activity Log',
      'floatingButtonHide': 'Hide Log',
      'metricsLoading': 'Loading metrics...',
      'progressTitleRollingUpgrade': 'Rolling Upgrade',
      'progressTitleProxy': 'Applying Proxy',
    },
    'zh': <String, String>{
      'appTitle': 'Nanookjaro 工具箱',
      'searchHint': '搜索或跳转...',
      'activityLog': '活动日志',
      'hideLog': '收起日志',
      'showLog': '活动日志',
      'quickActionsTitle': '快捷操作',
      'quickActionSystemUpgrade': '升级向导',
      'quickActionRollingUpgrade': '一键滚动更新',
      'quickActionConfigureProxy': '代理对话框',
      'quickActionEnableProxy': '一键开启代理',
      'quickActionDisableProxy': '一键关闭代理',
      'quickActionDriverScan': '驱动扫描',
      'quickActionCleanCache': '清理缓存',
      'quickActionOpenLogs': '打开日志',
      'comingSoon': '即将推出',
      'rollingUpgradeRunning': '正在执行 pacman -Syu...',
      'rollingUpgradeSuccess': '系统更新完成',
      'rollingUpgradeNeedsPassword': '需要身份验证，请在终端执行交互式命令。',
      'rollingUpgradeFailed': '更新失败（退出码 {code}）。请查看日志。',
  'rollingUpgradeError': '执行更新失败：{error}',
      'proxyApplySuccess': '代理已更新',
      'proxyApplyCleared': '代理已清除',
      'proxyApplyFailed': '更新代理失败：{error}',
  'proxyApplyProgress': '正在应用代理设置...',
      'proxyDialogTitle': '配置代理',
      'proxyDialogDescription': '更新本次会话使用的代理环境变量。',
      'proxyFieldHttp': 'http_proxy',
      'proxyFieldHttps': 'https_proxy',
      'cancel': '取消',
      'apply': '应用',
      'systemOverviewTitle': '系统概览',
      'loading': '加载中...',
      'failedMetrics': '加载系统指标失败：{error}',
      'updateStatusAllGood': '全部软件包均为最新',
      'updateStatusPending': '{count} 个更新可用',
      'updateStatusReboot': ' · 建议重启',
      'upgradeNow': '立即升级',
      'updateCheckFailed': '更新检查失败：{error}',
      'filesystemTitle': '文件系统',
      'filesystemEmpty': '没有可用的文件系统数据',
      'filesystemFailed': '加载文件系统信息失败：{error}',
      'percentUsed': '已用 {value}%',
      'realtimeMetricsTitle': '实时指标',
      'metricCurrent': '当前',
      'metricLoad1m': '1 分钟负载',
      'metricSelected': '选择项',
      'metricCpu': 'CPU',
      'metricMemory': '内存',
      'metricMemoryShort': '内存',
      'loadSnapshot': '负载快照',
  'loadShort1': '1 分钟',
  'loadShort5': '5 分钟',
  'loadShort15': '15 分钟',
      'lastRefresh': '最近刷新',
      'proxyNone': '未配置代理',
      'proxyHttp': 'HTTP：{value}',
      'proxyHttps': 'HTTPS：{value}',
      'proxyBoth': 'HTTP：{http}\nHTTPS：{https}',
      'proxyMatch': '{value}',
      'cpuModel': 'CPU 型号',
      'cpuCores': '核心/线程',
      'cpuUsage': 'CPU 使用率',
      'memory': '内存',
      'swap': '交换分区',
      'swapNotConfigured': '未配置',
      'loadAverage': '平均负载 (1/5/15)',
      'gpu': 'GPU',
      'proxy': '代理',
      'memoryUtilized': '{used} GB / {total} GB\n已用 {percent}%',
      'swapUtilized': '{used} GB / {total} GB\n已用 {percent}%',
      'logDrawerDescription': '最近的操作会显示在这里。升级流程和驱动操作将带有时间戳记录。',
      'proxyAutoYes': '自动确认 (--noconfirm)',
      'proxyAutoYesSubtitle': '在升级过程中跳过手动确认',
    'upgradeDescription':
      'Nanookjaro 将尝试在非交互模式下执行 pacman -Syu。如果需要 sudo 验证，将提示你转到终端继续。',
      'runUpgrade': '执行升级',
      'close': '关闭',
      'retry': '重试',
      'cancelLower': '取消',
      'copyCommand': '命令已复制到剪贴板',
      'copyInteractive': '复制交互式命令',
      'noOutput': '（无输出）',
      'commandOutput': '命令输出',
      'nonInteractiveCommand': '非交互命令：{command}',
      'interactiveCommand': '交互命令：{command}',
      'upgradeRunning': '正在执行 pacman -Syu...',
      'upgradeCompleted': '升级成功完成',
      'upgradePasswordRequired': '需要密码，请在终端继续执行',
      'upgradeFailedExit': '升级失败（退出码 {code}）',
      'upgradeInvokeFailed': '调用 pacman 升级失败',
      'upgradeDialogTitle': '执行系统升级',
      'upgradeDialogResultTitle': '升级结果',
      'languageSystem': '跟随系统',
      'languageEnglish': 'English',
      'languageChinese': '中文',
      'languageMenu': '语言',
      'proxyDialogLabel': '代理对话框',
      'floatingButtonShow': '活动日志',
      'floatingButtonHide': '收起日志',
      'metricsLoading': '正在加载指标...',
      'progressTitleRollingUpgrade': '滚动更新',
      'progressTitleProxy': '应用代理',
    },
  };

  String _value(String key) {
    final languageCode = locale.languageCode.toLowerCase();
    final values = _localizedValues[languageCode] ?? _localizedValues['en']!;
    return values[key] ?? _localizedValues['en']![key] ?? key;
  }

  String _format(String key, Map<String, String> params) {
    var template = _value(key);
    params.forEach((name, value) {
      template = template.replaceAll('{$name}', value);
    });
    return template;
  }

  String get appTitle => _value('appTitle');
  String get searchHint => _value('searchHint');
  String get activityLog => _value('activityLog');
  String get hideLog => _value('hideLog');
  String get showLog => _value('showLog');
  String get quickActionsTitle => _value('quickActionsTitle');
  String get quickActionSystemUpgrade => _value('quickActionSystemUpgrade');
  String get quickActionRollingUpgrade => _value('quickActionRollingUpgrade');
  String get quickActionConfigureProxy => _value('quickActionConfigureProxy');
  String get quickActionEnableProxy => _value('quickActionEnableProxy');
  String get quickActionDisableProxy => _value('quickActionDisableProxy');
  String get quickActionDriverScan => _value('quickActionDriverScan');
  String get quickActionCleanCache => _value('quickActionCleanCache');
  String get quickActionOpenLogs => _value('quickActionOpenLogs');
  String get comingSoon => _value('comingSoon');
  String get rollingUpgradeRunning => _value('rollingUpgradeRunning');
  String get rollingUpgradeSuccess => _value('rollingUpgradeSuccess');
  String rollingUpgradeFailed(int code) => _format('rollingUpgradeFailed', {'code': '$code'});
  String get rollingUpgradeNeedsPassword => _value('rollingUpgradeNeedsPassword');
  String rollingUpgradeError(Object error) => _format('rollingUpgradeError', {'error': '$error'});
  String get proxyApplySuccess => _value('proxyApplySuccess');
  String get proxyApplyCleared => _value('proxyApplyCleared');
  String proxyApplyFailed(Object error) => _format('proxyApplyFailed', {'error': '$error'});
  String get proxyApplyProgress => _value('proxyApplyProgress');
  String get proxyDialogTitle => _value('proxyDialogTitle');
  String get proxyDialogDescription => _value('proxyDialogDescription');
  String get proxyFieldHttp => _value('proxyFieldHttp');
  String get proxyFieldHttps => _value('proxyFieldHttps');
  String get proxyHint => _value('proxyHint');
  String get cancel => _value('cancel');
  String get apply => _value('apply');
  String get systemOverviewTitle => _value('systemOverviewTitle');
  String get loading => _value('loading');
  String failedMetrics(Object error) => _format('failedMetrics', {'error': '$error'});
  String get updateStatusAllGood => _value('updateStatusAllGood');
  String updateStatusPending(int count) => _format('updateStatusPending', {'count': '$count'});
  String get updateStatusReboot => _value('updateStatusReboot');
  String get upgradeNow => _value('upgradeNow');
  String updateCheckFailed(Object error) => _format('updateCheckFailed', {'error': '$error'});
  String get filesystemTitle => _value('filesystemTitle');
  String get filesystemEmpty => _value('filesystemEmpty');
  String filesystemFailed(Object error) => _format('filesystemFailed', {'error': '$error'});
  String percentUsed(String value) => _format('percentUsed', {'value': value});
  String get realtimeMetricsTitle => _value('realtimeMetricsTitle');
  String get metricCurrent => _value('metricCurrent');
  String get metricLoad1m => _value('metricLoad1m');
  String get metricSelected => _value('metricSelected');
  String get metricCpu => _value('metricCpu');
  String get metricMemory => _value('metricMemory');
  String get metricMemoryShort => _value('metricMemoryShort');
  String get loadSnapshot => _value('loadSnapshot');
  String get loadShort1 => _value('loadShort1');
  String get loadShort5 => _value('loadShort5');
  String get loadShort15 => _value('loadShort15');
  String get lastRefresh => _value('lastRefresh');
  String get proxyNone => _value('proxyNone');
  String proxyHttp(String value) => _format('proxyHttp', {'value': value});
  String proxyHttps(String value) => _format('proxyHttps', {'value': value});
  String proxyBoth(String http, String https) => _format('proxyBoth', {'http': http, 'https': https});
  String proxyMatch(String value) => _format('proxyMatch', {'value': value});
  String get cpuModel => _value('cpuModel');
  String get cpuCores => _value('cpuCores');
  String get cpuUsage => _value('cpuUsage');
  String get memory => _value('memory');
  String get swap => _value('swap');
  String get swapNotConfigured => _value('swapNotConfigured');
  String get loadAverage => _value('loadAverage');
  String get gpu => _value('gpu');
  String get proxy => _value('proxy');
  String memoryUtilized(String used, String total, String percent) =>
      _format('memoryUtilized', {'used': used, 'total': total, 'percent': percent});
  String swapUtilized(String used, String total, String percent) =>
      _format('swapUtilized', {'used': used, 'total': total, 'percent': percent});
  String get logDrawerDescription => _value('logDrawerDescription');
  String get proxyAutoYes => _value('proxyAutoYes');
  String get proxyAutoYesSubtitle => _value('proxyAutoYesSubtitle');
  String get upgradeDescription => _value('upgradeDescription');
  String get runUpgrade => _value('runUpgrade');
  String get close => _value('close');
  String get retry => _value('retry');
  String get cancelLower => _value('cancelLower');
  String get copyCommand => _value('copyCommand');
  String get copyInteractive => _value('copyInteractive');
  String get noOutput => _value('noOutput');
  String get commandOutput => _value('commandOutput');
  String nonInteractiveCommand(String command) =>
      _format('nonInteractiveCommand', {'command': command});
  String interactiveCommand(String command) =>
      _format('interactiveCommand', {'command': command});
  String get upgradeRunning => _value('upgradeRunning');
  String get upgradeCompleted => _value('upgradeCompleted');
  String get upgradePasswordRequired => _value('upgradePasswordRequired');
  String upgradeFailedExit(int code) => _format('upgradeFailedExit', {'code': '$code'});
  String get upgradeInvokeFailed => _value('upgradeInvokeFailed');
  String get upgradeDialogTitle => _value('upgradeDialogTitle');
  String get upgradeDialogResultTitle => _value('upgradeDialogResultTitle');
  String get languageSystem => _value('languageSystem');
  String get languageEnglish => _value('languageEnglish');
  String get languageChinese => _value('languageChinese');
  String get languageMenu => _value('languageMenu');
  String get proxyDialogLabel => _value('proxyDialogLabel');
  String get floatingButtonShow => _value('floatingButtonShow');
  String get floatingButtonHide => _value('floatingButtonHide');
  String get metricsLoading => _value('metricsLoading');
  String get progressTitleRollingUpgrade => _value('progressTitleRollingUpgrade');
  String get progressTitleProxy => _value('progressTitleProxy');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any((supported) => supported.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

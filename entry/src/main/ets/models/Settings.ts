/**
 * 字体大小枚举
 */
export enum FontSizeLevel {
  SMALL = 0,
  MEDIUM = 1,
  LARGE = 2,
  EXTRA_LARGE = 3,
  EXTRA_EXTRA_LARGE = 4
}

/**
 * 字体大小配置
 */
export interface FontSizeConfig {
  level: FontSizeLevel;
  label: string;
  fontSize: number;
  iconSize: number;
}

/**
 * 字体大小预设
 */
export const FONT_SIZE_PRESETS: FontSizeConfig[] = [
  { level: FontSizeLevel.SMALL, label: '小', fontSize: 14, iconSize: 60 },
  { level: FontSizeLevel.MEDIUM, label: '中', fontSize: 18, iconSize: 70 },
  { level: FontSizeLevel.LARGE, label: '大', fontSize: 22, iconSize: 80 },
  { level: FontSizeLevel.EXTRA_LARGE, label: '超大', fontSize: 26, iconSize: 90 },
  { level: FontSizeLevel.EXTRA_EXTRA_LARGE, label: '特大', fontSize: 30, iconSize: 100 }
];

/**
 * 应用设置
 */
export class AppSettings {
  fontSize: FontSizeLevel;
  voiceEnabled: boolean;
  voiceSpeed: number;

  constructor() {
    this.fontSize = FontSizeLevel.LARGE;
    this.voiceEnabled = true;
    this.voiceSpeed = 1.0;
  }

  static fromJson(json: Record<string => Object>): AppSettings {
    const settings = new AppSettings();
    settings.fontSize = (json['fontSize'] as FontSizeLevel) ?? FontSizeLevel.LARGE;
    settings.voiceEnabled = json['voiceEnabled'] as boolean ?? true;
    settings.voiceSpeed = json['voiceSpeed'] as number ?? 1.0;
    return settings;
  }

  toJson(): Record<string => Object> {
    return {
      fontSize: this.fontSize,
      voiceEnabled: this.voiceEnabled,
      voiceSpeed: this.voiceSpeed
    };
  }

  getFontSizeConfig(): FontSizeConfig {
    return FONT_SIZE_PRESETS[this.fontSize];
  }
}

## Stage
1. Normal
    1. Turret 2 x
    2. Plus 5 x
    3. White 7 x
    4. Large_R 10 x
    5. Large_C 12 x
    6. ExplosionEnemy 14 x
    7. Micro_M 16 x
    8. Slow_G 18 x
    9. M_Boss_Y(Boss) 1000 x
2. Mini
    1. Turret_S 2 x
    2. Plus_S 5 x
    3. White_S 8 x
    4. Slime 6 x
    5. Decay 7 x
    6. Division 10 x
    7. Duplication 13 x
    8. ExplosionEnemy_Micro 16 x
    9. Micro_Y 18 x
    10. Ghost 15 x
    11. Formation(Boss) 1400 x
3. Large
    1. Poison 6 x
    2. AntiPlasmaField 8 x
    3. Boost 10 x
    4. Teleport 13 x
    5. Amplification 15 x
    6. AntiBullet 18 x
    7. AntiExplosion 20 x
    8. AntiSkill 23 x
    9. EnemyShield(Boss) 1850 x
4. Range
    1. Bound 8 x
    2. AntiBulletField 11 x
    3. CollisionEnemy 14 x
    4. Decoy 25 x
    5. Recover(M_Boss) 500 x
    6. AntiG_Shot 25 x
    7. Barrier(Boss) 2500 x
5. Remix
    1. GoldEnemy 100 x
    2. SnipeEnemy(M_Boss) 200 x
    3. Sealed(Boss) 2750 x
6. Reprint
    1. Rare 4 x
    2. Zero 8 x
    3. Blaster 12 x
    4. Metal 16 x
    5. Explosion_B 20 x
    6. Rotate(M_Boss) 510 x
    7. Missile 24 x
    8. MirrorEnemy 28 x
    9. Defence 32 x
    10. Flash 36 x
    11. Missile_B(Boss) 3000 x
7. Innovation
    1. Slide 4 x
    2. Slime_F 8 x
    3. Magnet 12 x
    4. Boid 14 x
    5. Random 16~22 x
    6. Tornade 24 x
    7. Micro_C 26 x
    8. LinkEnemy 28 x
    9. BindEnemy 31 x
    10. Absorb(Boss) 3250 x
8. Sealed
    1. Sealed_Base 100 x
    2. Sealed_Shot 100 x//撃ってくるSealed
    3. Sealed_Gear 100 x//たまに周りのやつが高速回転して攻撃を跳ね返す。
    4. Sealed_Stun 100 x//無敵、HP0でスタン、10秒で復活
    5. Sealed_Multi 200 x//移動、回転射撃のステートを持つ。移動中のみ攻撃が通る。
9. Linked
    1. Crystal 3 x//赤色五角形
    2. Crystal_W 5 x//白色五角形
    3. Worm 7 x//連結
    4. Worm_R 8 x//赤
    5. IceDust 1 x//小さい水色五角形で物量攻め
    6. Gear 12 x//回転してダメージ軽減。回転中は仲間に当たる。
    7. Asteroid 2 x//妨害用六角形
    8. Asteroid_Core 8 x//Asteroidからたまに出てくるやつ。壊すと周囲の敵を殲滅。
    9.  IceChunk 2 x//Asteroidと同じ感じでIceDustが固まっている。壊すとIceDustになる。
    10. ARM 500 x//Gear強化版
10. Barrage
    1. Fixed_Turret 20 x
    2. Rotate_Turret_D 10 x//回転しながら2方向に発射
    3. Rotate_Turret_Q 12 x//回転しながら4方向に発射
    4. Bound_Turret 12 x//壁で跳ね返る弾を発射する
    5. Bound_Turret_D 14 x//壁で跳ね返る弾を2方向に発射する
    6. Self_Explosion 8 x//近づいたら自爆
    7. Circle_Turret 16 x//周りに円状に弾を発射する
    8. Homing_Turret 18 x//タレットがホーミング
    9.  Turret_Fast 20 x//高速弾タレット
    10. Turret_Laser 25 x//FF15のオメガみたいな攻撃をしてくる
    11. Disk_Turret 600 x//UFO的なアレ
11. Remix_2
    1. Δ
    2. γ
12. Chain
13. Dungeon
    1. Box 5 //破壊するタイプの箱
    2. Door //破壊不可能な扉
    3. Core 100 //Doorの動力源
    4. Pillar //ただの柱
    5. TNT //文字通り
    6. ElevetorButton //Elevetorを呼び出す
    7. Elevetor //Exit
14. Adventure
    1. LaserTrap //触れると死
    2. BoundTrap //BoundBullet発射
    3. SlideElevetor //into The END...
15. The END
    1. 

## TODO
- [x]スコア機能
- [x]Stage9(サブ武器なし、7min)
- [x]Stage10(サブ武器なし、10min)
- [ ]StateE2(ボスラッシュ、初期でInfinityShield)
- [ ]Stage11
- [ ]Stage12
- [ ]Stage13(10min)
- [ ]Stage14(10min)
- [ ]Stage15(ラスボス戦、10min)
- [x]スキン変更
- [x]StageListをソート
- [x]壁紙、スキンの選択画面で現在選択されているものを表示
- [x]スキンと背景の保存
- [ ]画面の揺れ
- [ ]最低画質
- [ ]ショップで画像表示
- [ ]音量設定
- [ ]プレイヤーの各動作にイベントを設定して、チュートリアルをイベント駆動型にすることでステージ設定ファイルに動作を記述する
- [x]曲のクレジット
- [x]完全レベルアップ後の対応
- [ ]Endress
- [ ]アチーブメントの表示(ステージ解放条件を明示)
- [ ]武器を開放していく方式に
- [ ]LAN内マルチプレイ
  - [ ]"{}|"はエスケープシーケンス
  - [ ]名前一致か"_"の場合にコマンド受け入れ
  - [ ]"_"によるコマンドは制限付き
- [ ]WANマルチプレイ(Ice server?)

Bullet>Enemy>Myself>Explosion>Wall
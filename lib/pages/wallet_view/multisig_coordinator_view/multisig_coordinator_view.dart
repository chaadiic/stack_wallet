import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../themes/stack_colors.dart';
import '../../../../utilities/text_styles.dart';
import '../../../../widgets/background.dart';
import '../../../widgets/custom_buttons/app_bar_icon_button.dart';
import '../../../widgets/desktop/primary_button.dart';
import '../../../widgets/desktop/secondary_button.dart';
import '../../../widgets/icon_widgets/copy_icon.dart';
import '../../../widgets/icon_widgets/qrcode_icon.dart';

final multisigCoordinatorStateProvider =
    StateNotifierProvider<MultisigCoordinatorState, MultisigCoordinatorData>(
        (ref) {
  return MultisigCoordinatorState();
});

class MultisigCoordinatorData {
  const MultisigCoordinatorData({
    this.threshold = 2,
    this.totalCosigners = 3,
    this.coinType = 0, // Bitcoin mainnet.
    this.accountIndex = 0,
    this.scriptType = MultisigScriptType.nativeSegwit,
    this.cosignerXpubs = const [],
  });

  final int threshold;
  final int totalCosigners;
  final int coinType;
  final int accountIndex;
  final MultisigScriptType scriptType;
  final List<String> cosignerXpubs;

  MultisigCoordinatorData copyWith({
    int? threshold,
    int? totalCosigners,
    int? coinType,
    int? accountIndex,
    MultisigScriptType? scriptType,
    List<String>? cosignerXpubs,
  }) {
    return MultisigCoordinatorData(
      threshold: threshold ?? this.threshold,
      totalCosigners: totalCosigners ?? this.totalCosigners,
      coinType: coinType ?? this.coinType,
      accountIndex: accountIndex ?? this.accountIndex,
      scriptType: scriptType ?? this.scriptType,
      cosignerXpubs: cosignerXpubs ?? this.cosignerXpubs,
    );
  }

  Map<String, dynamic> toJson() => {
        'threshold': threshold,
        'totalCosigners': totalCosigners,
        'coinType': coinType,
        'accountIndex': accountIndex,
        'scriptType': scriptType.index,
        'cosignerXpubs': cosignerXpubs,
      };

  factory MultisigCoordinatorData.fromJson(Map<String, dynamic> json) {
    return MultisigCoordinatorData(
      threshold: json['threshold'] as int,
      totalCosigners: json['totalCosigners'] as int,
      coinType: json['coinType'] as int,
      accountIndex: json['accountIndex'] as int,
      scriptType: MultisigScriptType.values[json['scriptType'] as int],
      cosignerXpubs: (json['cosignerXpubs'] as List).cast<String>(),
    );
  }
}

enum MultisigScriptType {
  legacy, // P2SH.
  segwit, // P2SH-P2WSH.
  nativeSegwit, // P2WSH.
}

class MultisigCoordinatorState extends StateNotifier<MultisigCoordinatorData> {
  MultisigCoordinatorState() : super(const MultisigCoordinatorData());

  void updateThreshold(int threshold) {
    state = state.copyWith(threshold: threshold);
  }

  void updateTotalCosigners(int total) {
    state = state.copyWith(totalCosigners: total);
  }

  void updateScriptType(MultisigScriptType type) {
    state = state.copyWith(scriptType: type);
  }

  void addCosignerXpub(String xpub) {
    if (state.cosignerXpubs.length < state.totalCosigners) {
      state = state.copyWith(
        cosignerXpubs: [...state.cosignerXpubs, xpub],
      );
    }
  }
}

class MultisigCoordinatorView extends ConsumerStatefulWidget {
  const MultisigCoordinatorView({
    super.key,
    required this.walletId,
    required this.totalCosigners,
    required this.threshold,
  });

  final String walletId;
  final int totalCosigners;
  final int threshold;

  static const String routeName = "/multisigCoordinator";

  @override
  ConsumerState<MultisigCoordinatorView> createState() =>
      _MultisigSetupViewState();
}

class _MultisigSetupViewState extends ConsumerState<MultisigCoordinatorView> {
  final List<TextEditingController> xpubControllers = [];
  // bool _isNfcAvailable = false;
  // String _nfcStatus = 'Checking NFC availability...';

  @override
  void initState() {
    super.initState();

    // Initialize controllers.
    for (int i = 0; i < widget.totalCosigners; i++) {
      xpubControllers.add(TextEditingController());
    }

    // _checkNfcAvailability();
  }

  @override
  void dispose() {
    for (final controller in xpubControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Future<void> _checkNfcAvailability() async {
  //   try {
  //     final availability = await NfcManager.instance.isAvailable();
  //     setState(() {
  //       _isNfcAvailable = availability;
  //       _nfcStatus = _isNfcAvailable
  //           ? 'NFC is available'
  //           : 'NFC is not available on this device';
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _nfcStatus = 'Error checking NFC: $e';
  //       _isNfcAvailable = false;
  //     });
  //   }
  // }
  //
  // Future<void> _startNfcSession() async {
  //   if (!_isNfcAvailable) return;
  //
  //   setState(() => _nfcStatus = 'Ready to exchange information...');
  //
  //   try {
  //     await NfcManager.instance.startSession(
  //       onDiscovered: (tag) async {
  //         try {
  //           final ndef = Ndef.from(tag);
  //
  //           if (ndef == null) {
  //             setState(() => _nfcStatus = 'Tag is not NDEF compatible');
  //             return;
  //           }
  //
  //           final setupData = ref.watch(multisigSetupStateProvider);
  //
  //           if (ndef.isWritable) {
  //             final message = NdefMessage([
  //               NdefRecord.createMime(
  //                 'application/x-multisig-setup',
  //                 Uint8List.fromList(
  //                     utf8.encode(jsonEncode(setupData.toJson()))),
  //               ),
  //             ]);
  //
  //             try {
  //               await ndef.write(message);
  //               setState(
  //                   () => _nfcStatus = 'Configuration shared successfully');
  //             } catch (e) {
  //               setState(
  //                   () => _nfcStatus = 'Failed to share configuration: $e');
  //             }
  //           }
  //
  //           await NfcManager.instance.stopSession();
  //         } catch (e) {
  //           setState(() => _nfcStatus = 'Error during NFC exchange: $e');
  //           await NfcManager.instance.stopSession();
  //         }
  //       },
  //     );
  //   } catch (e) {
  //     setState(() => _nfcStatus = 'Error: $e');
  //     await NfcManager.instance.stopSession();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SafeArea(
        child: Scaffold(
          backgroundColor:
              Theme.of(context).extension<StackColors>()!.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: AppBarBackButton(
              onPressed: () async {
                if (FocusScope.of(context).hasFocus) {
                  FocusScope.of(context).unfocus();
                  await Future<void>.delayed(const Duration(milliseconds: 75));
                }
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
            title: Text(
              "Enter cosigner xpubs",
              style: STextStyles.navBarTitle(context),
            ),
            titleSpacing: 0,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "This is your extended public key (xpub) for each cosigner.  "
                            "Share it with each participant.",
                            style: STextStyles.itemSubtitle(context),
                          ),
                          const SizedBox(height: 24),

                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Your xpub",
                                  style: STextStyles.w500_14(context).copyWith(
                                    color: Theme.of(context)
                                        .extension<StackColors>()!
                                        .textDark3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: xpubControllers[0],
                                        enabled:
                                            false, // Make field non-interactive
                                        decoration: InputDecoration(
                                          hintText: "xpub...",
                                          hintStyle:
                                              STextStyles.fieldLabel(context),
                                          filled:
                                              true, // Add background to show disabled state
                                          fillColor: Theme.of(context)
                                              .extension<StackColors>()!
                                              .textFieldDefaultBG,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SecondaryButton(
                                      width: 44,
                                      buttonHeight: ButtonHeight.xl,
                                      icon: QrCodeIcon(
                                        width: 20,
                                        height: 20,
                                        color: Theme.of(context)
                                            .extension<StackColors>()!
                                            .buttonTextSecondary,
                                      ),
                                      onPressed: () {
                                        // TODO: Implement QR code scanning
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    SecondaryButton(
                                      width: 44,
                                      buttonHeight: ButtonHeight.xl,
                                      icon: CopyIcon(
                                        width: 20,
                                        height: 20,
                                        color: Theme.of(context)
                                            .extension<StackColors>()!
                                            .buttonTextSecondary,
                                      ),
                                      onPressed: () async {
                                        final data = await Clipboard.getData(
                                            'text/plain');
                                        if (data?.text != null) {
                                          xpubControllers[0].text = data!.text!;
                                          ref
                                              .read(
                                                  multisigCoordinatorStateProvider
                                                      .notifier)
                                              .addCosignerXpub(data.text!);
                                          setState(
                                              () {}); // Trigger rebuild to update button state.
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Text(
                            "Enter the extended public key (xpub) for each cosigner.  "
                            "These can be obtained from each participant's wallet.",
                            style: STextStyles.itemSubtitle(context),
                          ),
                          const SizedBox(height: 24),

                          // Generate input fields for each cosigner.
                          for (int i = 0; i < widget.totalCosigners; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Cosigner ${i + 1} xpub",
                                    style:
                                        STextStyles.w500_14(context).copyWith(
                                      color: Theme.of(context)
                                          .extension<StackColors>()!
                                          .textDark3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: xpubControllers[i],
                                          decoration: InputDecoration(
                                            hintText: "Enter xpub",
                                            hintStyle:
                                                STextStyles.fieldLabel(context),
                                          ),
                                          onChanged: (value) {
                                            if (value.isNotEmpty) {
                                              ref
                                                  .read(
                                                      multisigCoordinatorStateProvider
                                                          .notifier)
                                                  .addCosignerXpub(value);
                                            }
                                            setState(
                                                () {}); // Trigger rebuild to update button state.
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SecondaryButton(
                                        width: 44,
                                        buttonHeight: ButtonHeight.xl,
                                        icon: QrCodeIcon(
                                          width: 20,
                                          height: 20,
                                          color: Theme.of(context)
                                              .extension<StackColors>()!
                                              .buttonTextSecondary,
                                        ),
                                        onPressed: () {
                                          // TODO: Implement QR code scanning
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      SecondaryButton(
                                        width: 44,
                                        buttonHeight: ButtonHeight.xl,
                                        icon: CopyIcon(
                                          width: 20,
                                          height: 20,
                                          color: Theme.of(context)
                                              .extension<StackColors>()!
                                              .buttonTextSecondary,
                                        ),
                                        onPressed: () async {
                                          final data = await Clipboard.getData(
                                              'text/plain');
                                          if (data?.text != null) {
                                            xpubControllers[i].text =
                                                data!.text!;
                                            ref
                                                .read(
                                                    multisigCoordinatorStateProvider
                                                        .notifier)
                                                .addCosignerXpub(data.text!);
                                            setState(
                                                () {}); // Trigger rebuild to update button state.
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                          const Spacer(),

                          PrimaryButton(
                            label: "Create multisignature account",
                            enabled: xpubControllers.every(
                                (controller) => controller.text.isNotEmpty),
                            onPressed: () {
                              // TODO.
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
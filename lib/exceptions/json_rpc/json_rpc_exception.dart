/*
 * This file is part of Stack Wallet.
 *
 * Copyright (c) 2023 Cypher Stack
 * All Rights Reserved.
 * The code is distributed under GPLv3 license, see LICENSE file for details.
 * Generated by Cypher Stack on 2023-05-26
 *
 */

import 'package:stackwallet/exceptions/sw_exception.dart';

class JsonRpcException implements SWException {
  JsonRpcException(this.message);

  @override
  final String message;

  @override
  toString() => message;
}
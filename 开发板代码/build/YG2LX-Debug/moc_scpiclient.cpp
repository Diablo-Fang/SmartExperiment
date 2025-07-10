/****************************************************************************
** Meta object code from reading C++ file 'scpiclient.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.15.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "../../scpiclient.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'scpiclient.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.15.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_ScpiClient_t {
    QByteArrayData data[23];
    char stringdata0[302];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_ScpiClient_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_ScpiClient_t qt_meta_stringdata_ScpiClient = {
    {
QT_MOC_LITERAL(0, 0, 10), // "ScpiClient"
QT_MOC_LITERAL(1, 11, 18), // "hostAddressChanged"
QT_MOC_LITERAL(2, 30, 0), // ""
QT_MOC_LITERAL(3, 31, 11), // "portChanged"
QT_MOC_LITERAL(4, 43, 23), // "connectionStatusChanged"
QT_MOC_LITERAL(5, 67, 9), // "connected"
QT_MOC_LITERAL(6, 77, 12), // "dataReceived"
QT_MOC_LITERAL(7, 90, 4), // "data"
QT_MOC_LITERAL(8, 95, 13), // "errorOccurred"
QT_MOC_LITERAL(9, 109, 11), // "errorString"
QT_MOC_LITERAL(10, 121, 15), // "connectToDevice"
QT_MOC_LITERAL(11, 137, 20), // "disconnectFromDevice"
QT_MOC_LITERAL(12, 158, 11), // "sendCommand"
QT_MOC_LITERAL(13, 170, 7), // "command"
QT_MOC_LITERAL(14, 178, 11), // "onConnected"
QT_MOC_LITERAL(15, 190, 14), // "onDisconnected"
QT_MOC_LITERAL(16, 205, 11), // "onReadyRead"
QT_MOC_LITERAL(17, 217, 7), // "onError"
QT_MOC_LITERAL(18, 225, 28), // "QAbstractSocket::SocketError"
QT_MOC_LITERAL(19, 254, 11), // "socketError"
QT_MOC_LITERAL(20, 266, 18), // "processPendingData"
QT_MOC_LITERAL(21, 285, 11), // "hostAddress"
QT_MOC_LITERAL(22, 297, 4) // "port"

    },
    "ScpiClient\0hostAddressChanged\0\0"
    "portChanged\0connectionStatusChanged\0"
    "connected\0dataReceived\0data\0errorOccurred\0"
    "errorString\0connectToDevice\0"
    "disconnectFromDevice\0sendCommand\0"
    "command\0onConnected\0onDisconnected\0"
    "onReadyRead\0onError\0QAbstractSocket::SocketError\0"
    "socketError\0processPendingData\0"
    "hostAddress\0port"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_ScpiClient[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
      13,   14, // methods
       3,  102, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       5,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    0,   79,    2, 0x06 /* Public */,
       3,    0,   80,    2, 0x06 /* Public */,
       4,    1,   81,    2, 0x06 /* Public */,
       6,    1,   84,    2, 0x06 /* Public */,
       8,    1,   87,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
      10,    0,   90,    2, 0x0a /* Public */,
      11,    0,   91,    2, 0x0a /* Public */,
      12,    1,   92,    2, 0x0a /* Public */,
      14,    0,   95,    2, 0x08 /* Private */,
      15,    0,   96,    2, 0x08 /* Private */,
      16,    0,   97,    2, 0x08 /* Private */,
      17,    1,   98,    2, 0x08 /* Private */,
      20,    0,  101,    2, 0x08 /* Private */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Bool,    5,
    QMetaType::Void, QMetaType::QString,    7,
    QMetaType::Void, QMetaType::QString,    9,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,   13,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, 0x80000000 | 18,   19,
    QMetaType::Void,

 // properties: name, type, flags
      21, QMetaType::QString, 0x00495103,
      22, QMetaType::Int, 0x00495103,
       5, QMetaType::Bool, 0x00495001,

 // properties: notify_signal_id
       0,
       1,
       2,

       0        // eod
};

void ScpiClient::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<ScpiClient *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->hostAddressChanged(); break;
        case 1: _t->portChanged(); break;
        case 2: _t->connectionStatusChanged((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 3: _t->dataReceived((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 4: _t->errorOccurred((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 5: _t->connectToDevice(); break;
        case 6: _t->disconnectFromDevice(); break;
        case 7: _t->sendCommand((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 8: _t->onConnected(); break;
        case 9: _t->onDisconnected(); break;
        case 10: _t->onReadyRead(); break;
        case 11: _t->onError((*reinterpret_cast< QAbstractSocket::SocketError(*)>(_a[1]))); break;
        case 12: _t->processPendingData(); break;
        default: ;
        }
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<int*>(_a[0]) = -1; break;
        case 11:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< QAbstractSocket::SocketError >(); break;
            }
            break;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (ScpiClient::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&ScpiClient::hostAddressChanged)) {
                *result = 0;
                return;
            }
        }
        {
            using _t = void (ScpiClient::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&ScpiClient::portChanged)) {
                *result = 1;
                return;
            }
        }
        {
            using _t = void (ScpiClient::*)(bool );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&ScpiClient::connectionStatusChanged)) {
                *result = 2;
                return;
            }
        }
        {
            using _t = void (ScpiClient::*)(const QString & );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&ScpiClient::dataReceived)) {
                *result = 3;
                return;
            }
        }
        {
            using _t = void (ScpiClient::*)(const QString & );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&ScpiClient::errorOccurred)) {
                *result = 4;
                return;
            }
        }
    }
#ifndef QT_NO_PROPERTIES
    else if (_c == QMetaObject::ReadProperty) {
        auto *_t = static_cast<ScpiClient *>(_o);
        Q_UNUSED(_t)
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< QString*>(_v) = _t->hostAddress(); break;
        case 1: *reinterpret_cast< int*>(_v) = _t->port(); break;
        case 2: *reinterpret_cast< bool*>(_v) = _t->isConnected(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
        auto *_t = static_cast<ScpiClient *>(_o);
        Q_UNUSED(_t)
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setHostAddress(*reinterpret_cast< QString*>(_v)); break;
        case 1: _t->setPort(*reinterpret_cast< int*>(_v)); break;
        default: break;
        }
    } else if (_c == QMetaObject::ResetProperty) {
    }
#endif // QT_NO_PROPERTIES
}

QT_INIT_METAOBJECT const QMetaObject ScpiClient::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_ScpiClient.data,
    qt_meta_data_ScpiClient,
    qt_static_metacall,
    nullptr,
    nullptr
} };


const QMetaObject *ScpiClient::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *ScpiClient::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_ScpiClient.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int ScpiClient::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 13)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 13;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 13)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 13;
    }
#ifndef QT_NO_PROPERTIES
    else if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 3;
    } else if (_c == QMetaObject::QueryPropertyDesignable) {
        _id -= 3;
    } else if (_c == QMetaObject::QueryPropertyScriptable) {
        _id -= 3;
    } else if (_c == QMetaObject::QueryPropertyStored) {
        _id -= 3;
    } else if (_c == QMetaObject::QueryPropertyEditable) {
        _id -= 3;
    } else if (_c == QMetaObject::QueryPropertyUser) {
        _id -= 3;
    }
#endif // QT_NO_PROPERTIES
    return _id;
}

// SIGNAL 0
void ScpiClient::hostAddressChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void ScpiClient::portChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void ScpiClient::connectionStatusChanged(bool _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 2, _a);
}

// SIGNAL 3
void ScpiClient::dataReceived(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 3, _a);
}

// SIGNAL 4
void ScpiClient::errorOccurred(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 4, _a);
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE

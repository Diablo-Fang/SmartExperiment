/****************************************************************************
** Meta object code from reading C++ file 'qmlprocess.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.15.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "../../qmlprocess.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'qmlprocess.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.15.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_MQP__QmlProcess_t {
    QByteArrayData data[22];
    char stringdata0[265];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_MQP__QmlProcess_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_MQP__QmlProcess_t qt_meta_stringdata_MQP__QmlProcess = {
    {
QT_MOC_LITERAL(0, 0, 15), // "MQP::QmlProcess"
QT_MOC_LITERAL(1, 16, 5), // "begin"
QT_MOC_LITERAL(2, 22, 0), // ""
QT_MOC_LITERAL(3, 23, 12), // "shellChanged"
QT_MOC_LITERAL(4, 36, 5), // "shell"
QT_MOC_LITERAL(5, 42, 14), // "commandChanged"
QT_MOC_LITERAL(6, 57, 7), // "command"
QT_MOC_LITERAL(7, 65, 8), // "finished"
QT_MOC_LITERAL(8, 74, 8), // "exitCode"
QT_MOC_LITERAL(9, 83, 20), // "QProcess::ExitStatus"
QT_MOC_LITERAL(10, 104, 10), // "exitStatus"
QT_MOC_LITERAL(11, 115, 22), // "readyReadStandardError"
QT_MOC_LITERAL(12, 138, 23), // "readyReadStandardOutput"
QT_MOC_LITERAL(13, 162, 7), // "started"
QT_MOC_LITERAL(14, 170, 10), // "doSometing"
QT_MOC_LITERAL(15, 181, 8), // "setShell"
QT_MOC_LITERAL(16, 190, 10), // "setCommand"
QT_MOC_LITERAL(17, 201, 5), // "start"
QT_MOC_LITERAL(18, 207, 9), // "terminate"
QT_MOC_LITERAL(19, 217, 4), // "kill"
QT_MOC_LITERAL(20, 222, 20), // "readAllStandardError"
QT_MOC_LITERAL(21, 243, 21) // "readAllStandardOutput"

    },
    "MQP::QmlProcess\0begin\0\0shellChanged\0"
    "shell\0commandChanged\0command\0finished\0"
    "exitCode\0QProcess::ExitStatus\0exitStatus\0"
    "readyReadStandardError\0readyReadStandardOutput\0"
    "started\0doSometing\0setShell\0setCommand\0"
    "start\0terminate\0kill\0readAllStandardError\0"
    "readAllStandardOutput"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_MQP__QmlProcess[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
      15,   14, // methods
       2,  116, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       7,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    0,   89,    2, 0x06 /* Public */,
       3,    1,   90,    2, 0x06 /* Public */,
       5,    1,   93,    2, 0x06 /* Public */,
       7,    2,   96,    2, 0x06 /* Public */,
      11,    0,  101,    2, 0x06 /* Public */,
      12,    0,  102,    2, 0x06 /* Public */,
      13,    0,  103,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
      14,    0,  104,    2, 0x0a /* Public */,
      15,    1,  105,    2, 0x0a /* Public */,
      16,    1,  108,    2, 0x0a /* Public */,
      17,    0,  111,    2, 0x0a /* Public */,
      18,    0,  112,    2, 0x0a /* Public */,
      19,    0,  113,    2, 0x0a /* Public */,

 // methods: name, argc, parameters, tag, flags
      20,    0,  114,    2, 0x02 /* Public */,
      21,    0,  115,    2, 0x02 /* Public */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,    4,
    QMetaType::Void, QMetaType::QString,    6,
    QMetaType::Void, QMetaType::Int, 0x80000000 | 9,    8,   10,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,    4,
    QMetaType::Void, QMetaType::QString,    6,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,

 // methods: parameters
    QMetaType::QString,
    QMetaType::QString,

 // properties: name, type, flags
       4, QMetaType::QString, 0x00495103,
       6, QMetaType::QString, 0x00495103,

 // properties: notify_signal_id
       1,
       2,

       0        // eod
};

void MQP::QmlProcess::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<QmlProcess *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->begin(); break;
        case 1: _t->shellChanged((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 2: _t->commandChanged((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 3: _t->finished((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< QProcess::ExitStatus(*)>(_a[2]))); break;
        case 4: _t->readyReadStandardError(QPrivateSignal()); break;
        case 5: _t->readyReadStandardOutput(QPrivateSignal()); break;
        case 6: _t->started(QPrivateSignal()); break;
        case 7: _t->doSometing(); break;
        case 8: _t->setShell((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 9: _t->setCommand((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 10: _t->start(); break;
        case 11: _t->terminate(); break;
        case 12: _t->kill(); break;
        case 13: { QString _r = _t->readAllStandardError();
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 14: { QString _r = _t->readAllStandardOutput();
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (QmlProcess::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&QmlProcess::begin)) {
                *result = 0;
                return;
            }
        }
        {
            using _t = void (QmlProcess::*)(const QString & );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&QmlProcess::shellChanged)) {
                *result = 1;
                return;
            }
        }
        {
            using _t = void (QmlProcess::*)(const QString & );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&QmlProcess::commandChanged)) {
                *result = 2;
                return;
            }
        }
        {
            using _t = void (QmlProcess::*)(int , QProcess::ExitStatus );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&QmlProcess::finished)) {
                *result = 3;
                return;
            }
        }
        {
            using _t = void (QmlProcess::*)(QPrivateSignal);
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&QmlProcess::readyReadStandardError)) {
                *result = 4;
                return;
            }
        }
        {
            using _t = void (QmlProcess::*)(QPrivateSignal);
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&QmlProcess::readyReadStandardOutput)) {
                *result = 5;
                return;
            }
        }
        {
            using _t = void (QmlProcess::*)(QPrivateSignal);
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&QmlProcess::started)) {
                *result = 6;
                return;
            }
        }
    }
#ifndef QT_NO_PROPERTIES
    else if (_c == QMetaObject::ReadProperty) {
        auto *_t = static_cast<QmlProcess *>(_o);
        Q_UNUSED(_t)
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< QString*>(_v) = _t->shell(); break;
        case 1: *reinterpret_cast< QString*>(_v) = _t->command(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
        auto *_t = static_cast<QmlProcess *>(_o);
        Q_UNUSED(_t)
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setShell(*reinterpret_cast< QString*>(_v)); break;
        case 1: _t->setCommand(*reinterpret_cast< QString*>(_v)); break;
        default: break;
        }
    } else if (_c == QMetaObject::ResetProperty) {
    }
#endif // QT_NO_PROPERTIES
}

QT_INIT_METAOBJECT const QMetaObject MQP::QmlProcess::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_MQP__QmlProcess.data,
    qt_meta_data_MQP__QmlProcess,
    qt_static_metacall,
    nullptr,
    nullptr
} };


const QMetaObject *MQP::QmlProcess::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *MQP::QmlProcess::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_MQP__QmlProcess.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int MQP::QmlProcess::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 15)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 15;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 15)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 15;
    }
#ifndef QT_NO_PROPERTIES
    else if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 2;
    } else if (_c == QMetaObject::QueryPropertyDesignable) {
        _id -= 2;
    } else if (_c == QMetaObject::QueryPropertyScriptable) {
        _id -= 2;
    } else if (_c == QMetaObject::QueryPropertyStored) {
        _id -= 2;
    } else if (_c == QMetaObject::QueryPropertyEditable) {
        _id -= 2;
    } else if (_c == QMetaObject::QueryPropertyUser) {
        _id -= 2;
    }
#endif // QT_NO_PROPERTIES
    return _id;
}

// SIGNAL 0
void MQP::QmlProcess::begin()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void MQP::QmlProcess::shellChanged(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}

// SIGNAL 2
void MQP::QmlProcess::commandChanged(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 2, _a);
}

// SIGNAL 3
void MQP::QmlProcess::finished(int _t1, QProcess::ExitStatus _t2)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))), const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t2))) };
    QMetaObject::activate(this, &staticMetaObject, 3, _a);
}

// SIGNAL 4
void MQP::QmlProcess::readyReadStandardError(QPrivateSignal _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 4, _a);
}

// SIGNAL 5
void MQP::QmlProcess::readyReadStandardOutput(QPrivateSignal _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 5, _a);
}

// SIGNAL 6
void MQP::QmlProcess::started(QPrivateSignal _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 6, _a);
}
struct qt_meta_stringdata_MQP__Private_t {
    QByteArrayData data[1];
    char stringdata0[13];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_MQP__Private_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_MQP__Private_t qt_meta_stringdata_MQP__Private = {
    {
QT_MOC_LITERAL(0, 0, 12) // "MQP::Private"

    },
    "MQP::Private"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_MQP__Private[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
       0,    0, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

       0        // eod
};

void MQP::Private::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    Q_UNUSED(_o);
    Q_UNUSED(_id);
    Q_UNUSED(_c);
    Q_UNUSED(_a);
}

QT_INIT_METAOBJECT const QMetaObject MQP::Private::staticMetaObject = { {
    QMetaObject::SuperData::link<QProcess::staticMetaObject>(),
    qt_meta_stringdata_MQP__Private.data,
    qt_meta_data_MQP__Private,
    qt_static_metacall,
    nullptr,
    nullptr
} };


const QMetaObject *MQP::Private::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *MQP::Private::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_MQP__Private.stringdata0))
        return static_cast<void*>(this);
    return QProcess::qt_metacast(_clname);
}

int MQP::Private::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QProcess::qt_metacall(_c, _id, _a);
    return _id;
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE

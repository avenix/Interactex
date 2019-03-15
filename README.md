Interactex
==========

Interactex is an environment to create smart textile applications that interact with a smartphone.

# Overview

 Figure below shows Interactex's high-level design and workflow. 

![alt tag](Documentation/images/Interactex/overview.png)

Interactex Designer is used to create the application and circuit design visually. Interactex Client executes applications and communicates with the smart textile. Interactex Client runs on a smartphone. Interactex Firmware runs on a microcontroller attached to the smart textile and executes commands received from Interactex Client. TextIT is used to create and export functionality components that can be imported into Interactex Designer.

## Interactex Designer

Interactex Designer runs on an iPad device and is available in the AppStore: 

https://itunes.apple.com/us/app/interactex-designer/id973912620?mt=8

The image below describes the main components of the user interface.

![alt tag](https://github.com/avenix/Interactex/blob/master/Documentation/images/Interactex/InteractexDesignerOverview.png)

Applications created in Interactex Designer are transferred wirelessly to Interactex Client. Interactex has three main modes: Circuit Layout, Visual Programming and Simulation Modes.

### Circuit Layout Mode

In Circuit Layout Mode, users lay out the hardware devices on the smart textile and draw their circuits.

![alt tag](Documentation/images/Interactex/circuitLayoutMode.png "circuit layout")

### Visual Programming Mode

In Visual Programming Mode, a palette with reusable objects is made available.

Interactex follows a flow-based programming paradigm. Events of an object are coupled to functions of another object.
 
![alt tag](Documentation/images/Interactex/visualProgrammingMode.png)

A new visual programming interface that will display object's events, methods and properties and their couplings is under development. A screenshot of the new visual programming interface is shown below:

![alt tag](Documentation/images/Interactex/newVisualProgramming.png)

### Simulation Mode

In Simulation Mode, applications are simulated and display runtime information for debugging purposes. Sensor data is simulated by users by performing multitouch gestures on sensors' visual representations. The states of output devices is represented visually with animations, sounds and images. 

![alt tag](Documentation/images/Interactex/simulationMode.png)

The screenshot below shows how different objects are represented in Simulation Mode.

![alt tag](Documentation/images/Interactex/simulationMode2.png)

## Interactex Client

Interactex Client is an iPhone and iPod App. Interactex Client is available in the AppStore: 
https://itunes.apple.com/nz/app/interactex-client/id1031238223?mt=8

![alt tag](Documentation/images/Interactex/InteractexClient.png)


## TextIT

TexIT is a hybrid visual and textual programming environment, currently under development. 

![alt tag](Documentation/images/Interactex/TextIT.png)

# Interactex Objects Overview

Interactex offers different types of reusable objects. 

## UI Widgets

UI Widgets conform the user interface on the smartphone. 

| Image                                               | Name         | Description                                                                                                                                |
|:---------------------------------------------------:|--------------|--------------------------------------------------------------------------------------------------------------------------------------------|
|   ![](Documentation/icons/ui/palette_ibutton.png)   |    Button    | Triggers events when pressed and when released.                                                                                            |
|    ![](Documentation/icons/ui/palette_label.png)    |     Label    | Displays text and numbers.                                                                                                                 |
|   ![](Documentation/icons/ui/palette_iswitch.png)   |    Switch    | Triggers events when switched on or off.                                                                                                   |
|    ![](Documentation/icons/ui/palette_slider.png)   |    Slider    | Used to select a value from a range of values. Triggers events when its handle is moved by the user.                                       |
|   ![](Documentation/icons/ui/palette_touchpad.png)  |   Touchpad   | Triggers events when the user performs the following multitouch gestures on it: tap, double tap, long tap, pinch and pan.                  |
| ![](Documentation/icons/ui/palette_musicplayer.png) | Music Player | Accesses mobile device's music library, offers functionality to iterate through the music list, play songs and displays music information. |
|  ![](Documentation/icons/ui/palette_imageview.png)  |  Image View  | Displays an image.                                                                                                                         |
| ![](Documentation/icons/ui/palette_contactBook.png) | Contact Book | Accesses user’s contact book and offers functionality to iterate through contacts and make calls.                                          |
|   ![](Documentation/icons/ui/palette_monitor.png)   |    Monitor   | Displays values over time (e.g. sensor readings).                                                                                          |


## Hardware Devices

Hardware devices are sensors and output devices. Interactex supports every hardware device in the Arduino Lilypad kit and custom-made textile sensors and output devices (e.g. Textile Sensor and Textile Speaker) 

|                              Image                              |        Name        |                                                                                                                                                                                                Description                                                                                                                                                                                               |
|:---------------------------------------------------------------:|:------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|        ![](Documentation/icons/hardware/palette_led.png)        |         LED        | A Light Emitting Diode (LED). Can be turned on or off and its intensity can be set (set the corresponding pin to PWM mode in the Lilypad info panel if you intend to change its intensity)                                                                                                                                                                                                               |
|       ![](Documentation/icons/hardware/palette_button.png)      |       Button       | A Lilypad button that can be pressed. Triggers events when pressed and when released.                                                                                                                                                                                                                                                                                                                    |
|       ![](Documentation/icons/hardware/palette_switch.png)      |       Switch       | A Lilypad switch. Generates events when switched on or off.                                                                                                                                                                                                                                                                                                                                              |
|       ![](Documentation/icons/hardware/palette_buzzer.png)      |       Buzzer       | Represents a Lilypad Buzzer, an element that produces a sound frequency. It can be turned on, turned off and its sound frequency can be set.                                                                                                                                                                                                                                                             |
|     ![](Documentation/icons/hardware/palette_LSMCompass.png)     |     LSMCompass     | Represents the LSM303 Accelerometer and Magnetometer. Should be connected to the SCL and SDA pins for I2C communication. Measures acceleration forces in a 3D space.                                                                                                                                                                                                                                     |
|       ![](Documentation/icons/hardware/palette_MPU6050.png)      |      MPU-6050      | Measures acceleration acceleration forces and orientation (gravity) in a 3D space.                                                                                                                                                                                                                                                                                                                       |
|     ![](Documentation/icons/hardware/palette_lightSensor.png)    |    Light Sensor    | Represents a Lilypad Light Sensor. Measures light intensity.                                                                                                                                                                                                                                                                                                                                             |
| ![](Documentation/icons/hardware/palette_temperatureSensor.png) | Temperature Sensor | Represents a Lilypad Temperature Sensor. It works similar to the Light Sensor. It offers an event: valueChanged which notifies when the reading of the sensor changed.                                                                                                                                                                                                                                   |
|   ![](Documentation/icons/hardware/palette_potentiometer.png)   |    Potentiometer   | Generates events according to three modes: always, InRange and Once. The Always mode will trigger an event whenever the hardware value changed. The InRange mode generates an event when the hardware value changed and this value lies within a certain range, which can be configured in the object’s properties. The Once mode will trigger an event once when the value lies within a certain range. |
|   ![](Documentation/icons/hardware/palette_threeColorLed.png)   |   Three-Color LED  | An LED that emits light in multiple colors.                                                                                                                                                                                                                                                                                                                                                              |
|     ![](Documentation/icons/hardware/palette_vibeBoard.png)     |     Vibe Board     | Represents a Lilypad vibration board (produces vibrations). It can be turned on, off and its vibration frequency can be set.                                                                                                                                                                                                                                                                             |
|   ![](Documentation/icons/hardware/palette_accelerometer.png)   |    Accelerometer   | It offers methods for reading x, y and z. Should be connected to three analog input pins.                                                                                                                                                                                                                                                                                                                |
|   ![](Documentation/icons/hardware/palette_textileSensor.png)   |   Textile Sensor   | Represents an analog textile sensor.                                                                                                                                                                                                                                                                                                                                                                     |
|   ![](Documentation/icons/hardware/palette_textileSpeaker.png)  |   Textile Speaker  | Represents a radio module. Its frequency, volume, sender can be configured.                                                                                                                                                                                                                                                                                                                              |

## Variables

Variables store data.

|                          Image                         |      Name     |                                                                                                                                                                            Description                                                                                                                                                                           |
|:-------------------------------------------------------:|:--------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|  ![](Documentation/icons/variables/palette_number.png) |  Number Value | Represents a number (equivalent to a variable in programming). Can be used for example together with the comparator in order to detect when a specific object’s property (such as the buzzer’s frequency or the LED’s intensity) reaches a specific value. Generates an event when its value changes. This is the event that can be connected to the comparator. |
| ![](Documentation/icons/variables/palette_boolean.png) | Boolean Value | Represents a Boolean value (equivalent to a variable in programming).  It can be used for example together with a grouper condition.                                                                                                                                                                                                                             |
|  ![](Documentation/icons/variables/palette_string.png) |  String Value | Represents a constant String (equivalent to a constant variable in programming). It can be used to set the text of a label. In the future, it will be formateable such that users can mix text and numbers, while these numbers could be sensor values.                                                                                                          |

## Comparison Operators

Comparison operators compare two values and return the result of the comparison as a Boolean.

|                             Image                             | Name         | Description                                                             |
|:-------------------------------------------------------------:|:-------------|:------------------------------------------------------------------------|
|    ![](Documentation/icons/programming/palette_bigger.png)    |    Bigger    | Compares whether the first operand is bigger than the second.           |
|    ![](Documentation/icons/programming/palette_bigger.png)    |  BiggerEqual | Compares whether the first operand is bigger or equal than the second.  |
|    ![](Documentation/icons/programming/palette_smaller.png)   |    Smaller   | Compares whether the first operand is smaller than the second.          |
| ![](Documentation/icons/programming/palette_smallerEqual.png) | SmallerEqual | Compares whether the first operand is smaller or equal than the second. |
|    ![](Documentation/icons/programming/palette_bigger.png)    |     Equal    | Compares whether the first operand is equal than the second.            |
|    ![](Documentation/icons/programming/palette_bigger.png)    |   NotEqual   | Compares whether the first operand is not equal to the second.          |
|      ![](Documentation/icons/programming/palette_and.png)     |      And     | Checks whether both operands are true.                                  |
|      ![](Documentation/icons/programming/palette_or.png)      |      Or      | Checks whether either operand is true.                                  |

## Arithmetic Operators

Arithmetic operators operate two numbers and return the result of the operation.

|                              Image                             |      Name      |                               Description                              |
|:--------------------------------------------------------------:|:---------------|:----------------------------------------------------------------------|
|    ![](Documentation/icons/arithmetic/palette_addition.png)    |    Addition    | Adds two numbers.                                                      |
|   ![](Documentation/icons/arithmetic/palette_subtraction.png)  |   Subtraction  | Subtracts operand2 from operand1.                                      |
| ![](Documentation/icons/arithmetic/palette_multiplication.png) | Multiplication | Multiplies two numbers.                                                |
|    ![](Documentation/icons/arithmetic/palette_division.png)    |    Division    | Divides operand1 by operand2.                                          |
|     ![](Documentation/icons/arithmetic/palette_modulo.png)     |     Modulo     | Calculates the residual of the division between operand1 and operand2. |



## Signal Processing

Signal processing elements are filters, feature extractors and classification algorithms.

|                                  Image                                  |         Name        |                                                                                      Description                                                                                      |
|:-----------------------------------------------------------------------:|:--------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|       ![](Documentation/icons/signalProcessing/palette_window.png)      |        Window       | Takes signal values as input, and returns chunks of the same signals, which might overlap.                                                                                            |
|   ![](Documentation/icons/signalProcessing/palette_lowPassFilter.png)   |   Low-Pass Filter   | Low-passes a signal.                                                                                                                                                                  |
|   ![](Documentation/icons/signalProcessing/palette_highPassFilter.png)  |   High-Pass Filter  | High-passes a signal.                                                                                                                                                                 |
|        ![](Documentation/icons/signalProcessing/palette_mean.png)       |    Mean Extractor   | Calculates the mean of a set of values.                                                                                                                                               |
|     ![](Documentation/icons/signalProcessing/palette_deviation.png)     | Deviation Extractor | Calculates the deviation of a set of values.                                                                                                                                          |
|    ![](Documentation/icons/signalProcessing/palette_peakDetector.png)   |    Peak Detector    | Calculates the peak in a set of values and provides the peak's value and index in an event. It offers methods to set the range in a set of samples where the peak should be searched. |
|     ![](Documentation/icons/signalProcessing/palette_classifier.png)    |  Motion Classifier  | Classifies user motion based on accelerometer input. Supported motions are: 'walking', 'running', 'climbing' and 'not moving'.                                                        |
| ![](Documentation/icons/signalProcessing/palette_postureClassifier.png) |  Posture Classifier | Clasifies user postures based on IMU input. Supported postures are: 'standing', 'lying down on stomach' and 'lying down on back'.                                                     |

## Utility Objects

Utility Objects represent software functionality commonly useful when developing software for smart textiles.

|                          Image                          |   Name   |                                                                                                                                                                                                            Description                                                                                                                                                                                                            |
|:-------------------------------------------------------:|:---------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|  ![](Documentation/icons/utilities/palette_mapper.png)  |  Mapper  | Scales values. This is useful to make values fit to the range required by other objects. For example, the Slider UI widget produces by default values in the range [0 255] and the Buzzer hardware element requires a frequency in the range [0 20000]. The Mapper would take the Slider's input range [Min1 Max1] and scale it linearly to the Buzzer's output range [Min2 Max2]. Generates an event whenever the value changes. |
| ![](Documentation/icons/utilities/palette_recorder.png) | Recorder | Provides a way to store a set of values (e.g. from a sensor) and to feed a set of values into other objects.                                                                                                                                                                                                                                                                                                                      |
|   ![](Documentation/icons/utilities/palette_timer.png)  |   Timer  | Generates an event after x time. It's trigger time and whether it should trigger once or many times can be configured over the properties panel.                                                                                                                                                                                                                                                                                  |
|   ![](Documentation/icons/utilities/palette_sound.png)  |   Sound  | Represents a sound. It offers a single method to play it.                                                                                                                                                                                                                                                                                                                                                                         |

# Object's Events, Methods and Properties

Objects in Interactex emit events and contain methods with executable functionality and properties (equivalent to instance variables in object-oriented programming). 

## UI Widgets
|                        Image                        |     Name     |                                    Events                                   |                         Methods                        |     Properties    |
|:---------------------------------------------------:|:------------:|:---------------------------------------------------------------------------:|:------------------------------------------------------:|:-----------------:|
|   ![](Documentation/icons/ui/palette_ibutton.png)   |    Button    |                      buttonPressed(), buttonReleased()                      |                            -                           | pressed : Boolean |
|    ![](Documentation/icons/ui/palette_label.png)    |     Label    |                                      -                                      |           setText(String), appendText(String)          |   text : String   |
|   ![](Documentation/icons/ui/palette_iswitch.png)   |    Switch    |               switchedOn(), switchedOff(), onChanged(Boolean)               |                            -                           |    on : Boolean   |
|    ![](Documentation/icons/ui/palette_slider.png)   |    Slider    |                             valueChanged(Number)                            |                            -                           |   value : Number  |
|   ![](Documentation/icons/ui/palette_touchpad.png)  |   Touchpad   | pannedX(Number), pannedY(Number), tapped(), doubleTapped(), pinched(Number) |                            -                           |         -         |
| ![](Documentation/icons/ui/palette_musicplayer.png) | Music Player |                             started(), stopped()                            | play(), pause(), next(), previous(), setVolume(Number) |  volume : Number  |
|  ![](Documentation/icons/ui/palette_imageview.png)  |  Image View  |                                      -                                      |                            -                           |         -         |
| ![](Documentation/icons/ui/palette_contactBook.png) | Contact Book |                                      -                                      |               call(), previous(), next()               |                   |
|   ![](Documentation/icons/ui/palette_monitor.png)   |    Monitor   |                                      -                                      |          addValue1(Number), addValue2(Number)          |         -         |


## Hardware Devices
|                              Image                              |        Name        |                          Events                         |                                      Methods                                     |                 Properties                |
|:---------------------------------------------------------------:|:------------------:|:-------------------------------------------------------:|:--------------------------------------------------------------------------------:|:-----------------------------------------:|
|        ![](Documentation/icons/hardware/palette_led.png)        |         LED        |                 turnedOn(), turnedOff()                 |                     turnOn(), turnOff(), setIntensity(Number)                    |      on : Boolean, intensity : Number     |
|       ![](Documentation/icons/hardware/palette_button.png)      |       Button       |            buttonPressed(), buttonReleased()            |                                         -                                        |             pressed : Boolean             |
|       ![](Documentation/icons/hardware/palette_switch.png)      |       Switch       |   switchedOn(), switchedOff(), switchChanged(Boolean)   |                                         -                                        |                     -                     |
|       ![](Documentation/icons/hardware/palette_buzzer.png)      |       Buzzer       |                            -                            |                     turnOn(), turnOff(), setFrequency(Number)                    |             frequency : Number            |
|     ![](Documentation/icons/hardware/palette_LSMCompass.png)     |     LSMCompass     |   headingChanged(Number), accelerationChanged(Object)   |                                         -                                        |  acceleration : Object, heading : Number  |
|       ![](Documentation/icons/hardware/palette_MPU6050.png)      |      MPU-6050      | accelerationChanged(Object), orientationChanged(Object) |                                  start(), stop()                                 | acceleration: Object, orientation: Object |
|     ![](Documentation/icons/hardware/palette_lightSensor.png)    |    Light Sensor    |                   valueChanged(Number)                  |                                  start(), stop()                                 |          lightIntensity : Number          |
| ![](Documentation/icons/hardware/palette_temperatureSensor.png) | Temperature Sensor |                   valueChanged(Number)                  |                                  start(), stop()                                 |            temperature : Number           |
|   ![](Documentation/icons/hardware/palette_potentiometer.png)   |    Potentiometer   |                   valueChanged(Number)                  |                                         -                                        |               value : Number              |
|   ![](Documentation/icons/hardware/palette_threeColorLed.png)   |   Three-Color LED  |                            -                            |      turnOn(), turnOff(), setRed(Number), setGreen(Number), setBlue(Number)      |                     -                     |
|     ![](Documentation/icons/hardware/palette_vibeBoard.png)     |     Vibe Board     |                            -                            |                     turnOn(), turnOff(), setFrequency(Number)                    |             frequency : Number            |
|   ![](Documentation/icons/hardware/palette_accelerometer.png)   |    Accelerometer   |  xChanged(Number), yChanged(Number), zChanged(Number),  |               xChanged(Number), yChanged(Number), zChanged(Number)               |     x : Number, y : Number, z : Number    |
|   ![](Documentation/icons/hardware/palette_textileSensor.png)   |   Textile Sensor   |                            -                            |                                                                                  |               value : Number              |
|   ![](Documentation/icons/hardware/palette_textileSpeaker.png)  |   Textile Speaker  |                    onChanged(Boolean)                   | turnOn(), turnOff(), setFrequency(Number), setVolume(Number), setSender(Boolean) |                     -                     |


## Comparison Operators

Comparison Operators emit the conditionIsTrue() event if the fist input variable is bigger (or smaller, equal, etc.) than the second input variable and otherwise emit the conditionIsFalse() event. Comparison Operators emit the alternative conditionChanged() event.

|                             Image                             |     Name     |                              Events                              |                Methods               |    Properties    |
|:-------------------------------------------------------------:|:------------:|:----------------------------------------------------------------:|:------------------------------------:|:----------------:|
|    ![](Documentation/icons/programming/palette_bigger.png)    |    Bigger    | conditionIsTrue(), conditionIsFalse(), conditionChanged(Boolean) | setValue1(Number), setValue2(Number) | isTrue : Boolean |
|    ![](Documentation/icons/programming/palette_bigger.png)    |  BiggerEqual | conditionIsTrue(), conditionIsFalse(), conditionChanged(Boolean) | setValue1(Number), setValue2(Number) | isTrue : Boolean |
|    ![](Documentation/icons/programming/palette_smaller.png)   |    Smaller   | conditionIsTrue(), conditionIsFalse(), conditionChanged(Boolean) | setValue1(Number), setValue2(Number) | isTrue : Boolean |
| ![](Documentation/icons/programming/palette_smallerEqual.png) | SmallerEqual | conditionIsTrue(), conditionIsFalse(), conditionChanged(Boolean) | setValue1(Number), setValue2(Number) | isTrue : Boolean |
|    ![](Documentation/icons/programming/palette_bigger.png)    |     Equal    | conditionIsTrue(), conditionIsFalse(), conditionChanged(Boolean) | setValue1(Number), setValue2(Number) | isTrue : Boolean |
|    ![](Documentation/icons/programming/palette_bigger.png)    |   NotEqual   | conditionIsTrue(), conditionIsFalse(), conditionChanged(Boolean) | setValue1(Number), setValue2(Number) | isTrue : Boolean |
|      ![](Documentation/icons/programming/palette_and.png)     |      And     | conditionIsTrue(), conditionIsFalse(), conditionChanged(Boolean) | setValue1(Number), setValue2(Number) | isTrue : Boolean |
|      ![](Documentation/icons/programming/palette_or.png)      |      Or      | conditionIsTrue(), conditionIsFalse(), conditionChanged(Boolean) | setValue1(Number), setValue2(Number) | isTrue : Boolean |


## Arithmetic Operators

Arithmetic Operators emit the computed(Number) event with the result of the operation.

|                              Image                              |      Name      |      Events      |                       Methods                       | Properties |
|:---------------------------------------------------------------:|:--------------:|:----------------:|:---------------------------------------------------:|:----------:|
|    ![](Documentation/icons/arithmetic/palette_addition.png)    |    Addition    | computed(Number) | setOperand1(Number), setOperand2(Number), compute() |      -     |
|    ![](Documentation/icons/arithmetic/palette_subtraction.png) |   Subtraction  | computed(Number) | setOperand1(Number), setOperand2(Number), compute() |      -     |
| ![](Documentation/icons/arithmetic/palette_multiplication.png) | Multiplication | computed(Number) | setOperand1(Number), setOperand2(Number), compute() |      -     |
|    ![](Documentation/icons/arithmetic/palette_division.png)    |    Division    | computed(Number) | setOperand1(Number), setOperand2(Number), compute() |      -     |
|     ![](Documentation/icons/arithmetic/palette_modulo.png)     |     Modulo     | computed(Number) | setOperand1(Number), setOperand2(Number), compute() |      -     |

## Variables

Variables have an event to set the value to be stored in the Variable and emit the valueChanged() event when the value changes its value. The value stored in a Variables can also be accessed through the 'value' property. 

|                           Image                          |      Name     |         Events        |      Methods      |    Properties   |
|:--------------------------------------------------------:|:-------------:|:---------------------:|:-----------------:|:---------------:|
|  ![](Documentation/icons/variables/palette_number.png) |  Number Value | valueChanged(Number) |  setValue(Number) |  value : Number |
| ![](Documentation/icons/variables/palette_boolean.png) | Boolean Value | valueChanged(Boolean) | setValue(Boolean) | value : Boolean |
|  ![](Documentation/icons/variables/palette_string.png) |  String Value | valueChanged(String) |  setValue(String) |  value : String |


## Signal Processing
|                                  Image                                  |         Name        |                     Events                    | Methods                                                                        | Properties |
|:-----------------------------------------------------------------------:|:-------------------:|:---------------------------------------------:|:------------------------------------------------------------------------------:|:----------:|
|       ![](Documentation/icons/signalProcessing/palette_window.png)      |        Window       |                 filled(Object)                |                                addValue(Number)                                |      -     |
|   ![](Documentation/icons/signalProcessing/palette_lowPassFilter.png)   |   Low-Pass Filter   |                filteredValues()               |                       addValue(Number), removeAllValues()                      |      -     |
|   ![](Documentation/icons/signalProcessing/palette_highPassFilter.png)  |   High-Pass Filter  |                filteredValues()               |                       addValue(Number), removeAllValues()                      |      -     |
|        ![](Documentation/icons/signalProcessing/palette_mean.png)       |    Mean Extractor   |               featureExtracted()              |                 addValue(Number), removeAllValues(), compute()                 |      -     |
|     ![](Documentation/icons/signalProcessing/palette_deviation.png)     | Deviation Extractor |               featureExtracted()              |                 addValue(Number), removeAllValues(), compute()                 |      -     |
|    ![](Documentation/icons/signalProcessing/palette_peakDetector.png)   |    Peak Detector    |               featureExtracted()              | addValue(Number), removeAllValues(), compute(), setRangeStart(), setRangeEnd() |      -     |
|     ![](Documentation/icons/signalProcessing/palette_classifier.png)    |  Motion Classifier  | walking(), running(), climbing(), notMoving() |                                addSample(Object)                               |      -     |
| ![](Documentation/icons/signalProcessing/palette_postureClassifier.png) |  Posture Classifier |       standing(), lyingDown(), lyingUp()      |                                addSample(Object)                               |      -     |


## Utilities
|                          Image                          |   Name   |               Events              |                                        Methods                                       |   Properties   |
|:-------------------------------------------------------:|:--------:|:---------------------------------:|:------------------------------------------------------------------------------------:|:--------------:|
|  ![](Documentation/icons/utilities/palette_mapper.png)  |  Mapper  |                 -                 | setMin1(Number), setMax1(Number), setMin2(Number), setMax2(Number), setValue(Number) | value : Number |
| ![](Documentation/icons/utilities/palette_recorder.png) | Recorder | startRecording(), stopRecording() |                  startRecording(), stopRecording(), addValue(Number)                 |        -       |
|   ![](Documentation/icons/utilities/palette_timer.png)  |   Timer  |            triggered()            |                                    start(), stop()                                   |        -       |
|   ![](Documentation/icons/utilities/palette_sound.png)  |   Sound  |        valueChanged(Number)       |                                        play()                                        |        -       |

## About
My name is Juan Haladjian. I developed the Wearables Development Toolkit as part of my post-doc at the Technical University of Munich. 

Feel free to contact me with feature requests:

[Email](mailto:haladjia@in.tum.de)

[Website](http://in.tum.de/~haladjia)

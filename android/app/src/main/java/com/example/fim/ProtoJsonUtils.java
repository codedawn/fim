package com.example.fim;

import com.codedawn.vital.server.proto.VitalPB;
import com.google.protobuf.util.JsonFormat;

import java.io.IOException;

/**
 * @author codedawn
 * @date 2021-08-28 13:56
 */
public class ProtoJsonUtils {

    public static String toJson(VitalPB.TextMessage sourceMessage)
            throws IOException {
        String json = JsonFormat.printer().printingEnumsAsInts().includingDefaultValueFields().print(sourceMessage);
        return json;
    }

    public static VitalPB.Frame toProtoBean(VitalPB.Frame.Builder targetBuilder, String json) throws IOException {
        JsonFormat.parser().merge(json, targetBuilder);
        return targetBuilder.build();
    }

}
